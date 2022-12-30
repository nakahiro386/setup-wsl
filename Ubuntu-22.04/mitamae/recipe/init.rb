
node[:target_user] ||= ENV['SUDO_USER']
user_info = node['user'][node[:target_user]]
p user_info

user = node[:target_user]
home = user_info[:directory]

architecture = run_command("dpkg --print-architecture").stdout.chomp
codename = run_command("lsb_release -cs").stdout.chomp

raise "rootでは実行しない。" if user == "root"

file File.join("/etc/sudoers.d", user) do
  action :create
  owner "root"
  group "root"
  mode "440"
  content <<-"EOH"
#{user} ALL=NOPASSWD: ALL
Defaults:#{user} env_keep += "EDITOR"
  EOH
end


file "/etc/wsl.conf" do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
[user]
default=#{user}
[boot]
systemd=true
[interop]
appendWindowsPath=false
EOH
end

# Systemd units known to be problematic under WSL · arkane-systems/genie Wiki
# https://github.com/arkane-systems/genie/wiki/Systemd-units-known-to-be-problematic-under-WSL#systemd-sysusersservice

# WSL: snaps with private shared memory support enabled don't install
# https://randombytes.substack.com/p/wsl-snaps-with-private-shared-memory
file "/etc/systemd/system/fixshm.service" do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
  [Unit]
Description=Fix the /dev/shm symlink to be a mount
DefaultDependencies=no
Before=sysinit.target
ConditionPathExists=/dev/shm
ConditionPathIsSymbolicLink=/dev/shm
ConditionPathIsMountPoint=/run/shm

[Service]
Type=oneshot
ExecStart=/usr/bin/rm /dev/shm
ExecStart=/usr/bin/mkdir /dev/shm
ExecStart=/bin/umount /run/shm
ExecStart=/usr/bin/rmdir /run/shm
ExecStart=/bin/mount -t tmpfs -o mode=1777,nosuid,nodev,strictatime tmpfs /dev/shm
ExecStart=/usr/bin/ln -s /dev/shm /run/shm

[Install]
WantedBy=sysinit.target
EOH
  notifies :restart, "service[fixshm.service]", :immediately
end
service "fixshm.service" do
  action :enable
end

%w(nano).each do |pkg|
  package pkg do
    action :remove
  end
end

file '/etc/apt/sources.list' do
  action :edit
  block do |content|
    content.gsub!(/http:\/\/[^ ]*archive.ubuntu.com\/ubuntu\//, "mirror://mirrors.ubuntu.com/mirrors.txt")
  end
  notifies :run, "execute[apt update]", :immediately
end

execute "docker.gpg" do
  command <<-"EOH"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
EOH
  not_if "test -f /etc/apt/keyrings/docker.gpg"
end

file '/etc/apt/sources.list.d/docker.list' do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
deb [arch=#{architecture} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu #{codename} stable
EOH
  notifies :run, "execute[apt update]", :immediately
end

execute "apt update" do
  command <<-"EOH"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
EOH
  action :nothing
end

%w(docker-ce docker-ce-cli containerd.io docker-compose-plugin uidmap openssh-server).each do |pkg|
  package pkg do
    action :install
  end
end

file '/etc/ssh/sshd_config' do
  action :edit
  block do |content|
    content.gsub!(/#?Port .*/, "Port 2204")
    content.gsub!(/#?PasswordAuthentication .*/, "PasswordAuthentication yes")
  end
  notifies :run, "execute[dpkg-reconfigure openssh-server]", :immediately
end
service "ssh.service" do
  action [:enable, :start]
end
execute "dpkg-reconfigure openssh-server" do
  command "dpkg-reconfigure --frontend noninteractive openssh-server"
  action :nothing
end

%w(docker.service docker.socket containerd.service).each do |name|
  service name do
    action [:disable, :stop]
  end
end


file File.join(home, ".hushlogin") do
  action :create
  user user
  owner user
  group user
  mode "644"
end

directory File.join(home, ".ssh") do
  action :create
  user user
  owner user
  group user
  mode "700"
end

%w(docker-ce docker-ce-cli containerd.io docker-compose-plugin uidmap openssh-server).each do |pkg|
  package pkg do
    action :install
  end
end

user_systemd_dir = ".config/systemd/user"
docker_service_fragment_dir = File.join(user_systemd_dir, "docker.service.d")

path = ""
docker_service_fragment_dir.split('/').each do |f|
  path = File.join(path, f)
  directory File.join(home, path) do
    action :create
    user user
    owner user
    group user
    mode "755"
  end
end

# docker: Error response from daemon: Get "https://registry-1.docker.io/v2/": dial tcp: lookup registry-1.docker.io on 10.0.2.3:53: read udp 10.0.2.100:51474->10.0.2.3:53: i/o timeout.
file File.join(home, docker_service_fragment_dir, "override.conf") do
  action :create
  owner user
  group user
  mode "644"
  content <<-"EOH"
[Service]
Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_SLIRP4NETNS_SANDBOX=false"
  EOH
end

file File.join(home, ".bashrc") do
  action :edit
  block do |content|
    unless content =~ /^export DOCKER_HOST/
      content.concat <<-CONF
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
      CONF
    end
  end
end

execute "sudo -i -u #{user} dockerd-rootless-setuptool.sh --skip-iptables install" do
  not_if "test -f #{File.join(home, user_systemd_dir, "docker.service")}"
end

