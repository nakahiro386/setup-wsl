
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

%w(build-essential software-properties-common aptitude needrestart bc zip unzip tree htop tmux vim-gtk3 libxml2-utils cmigemo python-is-python3 python3-pynvim vifm sshfs curlftpfs fuse3 fuse-zip fusefat fuseiso).each do |pkg|
  package pkg do
    action :install
  end
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

home_bin = File.join(home, "bin")
directory home_bin do
  action :create
  user user
  owner user
  group user
end

node[:gvim_version] ||= "v9.0.1107"
gvim_version = node[:gvim_version]

node[:gvim_bin] ||= "GVim-#{gvim_version}.glibc2.15-x86_64.AppImage"
gvim_bin = node[:gvim_bin]

node[:gvim_checksum] ||= "750bb46f34ae70937ff81e08336c5b51c53a7a66f0e0bbf6bec6594ea8bf4cb8"

node[:gvim_url] ||= "https://github.com/vim/vim-appimage/releases/download/#{gvim_version}/#{gvim_bin}"
download node[:gvim_url] do
  destination File.join(home_bin, gvim_bin)
  user user
  mode "755"
  checksum node[:gvim_checksum]
end
%w(vim gvim).each do |bin|
  link File.join(home_bin, bin) do
    to gvim_bin
    user user
    cwd home_bin
  end
end

node[:vifm_version] ||= "v0.12.1"
vifm_version = node[:vifm_version]

node[:vifm_bin] ||= "vifm-#{vifm_version}-x86_64.AppImage"
vifm_bin = node[:vifm_bin]

node[:vifm_checksum] ||= "2034d8e3e568fd3109526c48d3cdc8ed08d0bc3a3d2d76538fe293cbfc45fcc5"

node[:vifm_url] ||= "https://github.com/vifm/vifm/releases/download/#{vifm_version}/#{vifm_bin}"
download node[:vifm_url] do
  destination File.join(home_bin, vifm_bin)
  user user
  mode "755"
  checksum node[:vifm_checksum]
end
link File.join(home_bin, "vifm") do
  to vifm_bin
  user user
  cwd home_bin
end

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
