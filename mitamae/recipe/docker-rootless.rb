# Run the Docker daemon as a non-root user (Rootless mode) | Docker Documentation
# https://docs.docker.com/engine/security/rootless/
user = node[:docker_rootless][:user]
node[:docker_rootless][:home] ||= node['user'][user][:directory]
home = node[:docker_rootless][:home]

%w(docker-ce-rootless-extras uidmap).each do |pkg|
  package pkg do
    action :install
  end
end

%w(docker.service docker.socket containerd.service).each do |name|
  service name do
    action [:disable, :stop]
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

# file File.join(home, ".bashrc") do
  # action :edit
  # block do |content|
    # unless content =~ /^export DOCKER_HOST/
      # content.concat <<-CONF
# export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
      # CONF
    # end
  # end
# end

execute "sudo -i -u #{user} dockerd-rootless-setuptool.sh --skip-iptables install" do
  not_if "test -f #{File.join(home, user_systemd_dir, "docker.service")}"
end

