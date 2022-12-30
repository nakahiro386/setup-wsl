
node[:target_user] ||= ENV['SUDO_USER']
user_info = node['user'][node[:target_user]]
p user_info

user = node[:target_user]
home = user_info[:directory]

node[:docker_rootless] ||= {}
node[:docker_rootless][:user] = user

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
execute "apt update" do
  command <<-"EOH"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
  EOH
  action :nothing
end

# 日本語化
%w(language-pack-ja manpages-ja manpages-ja-dev).each do |pkg|
  package pkg
end

node[:locale] ||= 'ja_JP.UTF-8'
execute "set-locale" do
  command "localectl set-locale LANG=#{node[:locale]}"
  not_if "localectl status | grep 'LANG=#{node[:locale]}'"
end

include_recipe 'recipe/sshd'

directory File.join(home, ".ssh") do
  action :create
  user user
  owner user
  group user
  mode "700"
end

file File.join(home, ".hushlogin") do
  action :create
  user user
  owner user
  group user
  mode "644"
end

include_recipe 'docker'
include_recipe 'docker-rootless'

git_clone File.join(home, 'repo/github.com/nakahiro386/dotfiles') do
  repository "git@github.com:nakahiro386/dotfiles.git"
  user user
end

vimfiles = File.join(home, 'repo/github.com/nakahiro386/vimfiles')
git_clone "#{vimfiles}" do
  repository "git@github.com:nakahiro386/vimfiles.git"
  user user
end
link File.join(home, '.vim') do
  to vimfiles
  user user
end
