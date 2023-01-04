
node[:target_user] ||= ENV['SUDO_USER']
user_info = node['user'][node[:target_user]]
p user_info

user = node[:target_user]
node[:home] = user_info[:directory]
home = node[:home]

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

include_recipe 'recipe/fixshm'

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
include_recipe 'recipe/localize'

node[:present_packages].each do |pkg|
  package pkg
end
node[:absent_packages].each do |pkg|
  package pkg do
    action :remove
  end
end

include_recipe 'recipe/sshd'

directory File.join(node[:home], ".ssh") do
  action :create
  user user
  owner user
  group user
  mode "700"
end

directory File.join(node[:home], "bin") do
  action :create
  user user
  owner user
  group user
end

file File.join(node[:home], ".hushlogin") do
  action :create
  user user
  owner user
  group user
  mode "644"
end

node[:docker_rootless] ||= {}
node[:docker_rootless][:user] = user
include_recipe 'recipe/docker'
include_recipe 'recipe/docker-rootless'

# vim, vifm
include_recipe 'recipe/appimage'

git_clone File.join(node[:home], 'repo/github.com/nakahiro386/dotfiles') do
  repository "git@github.com:nakahiro386/dotfiles.git"
  user user
end

vimfiles = File.join(node[:home], 'repo/github.com/nakahiro386/vimfiles')
git_clone "#{vimfiles}" do
  repository "git@github.com:nakahiro386/vimfiles.git"
  user user
end
link File.join(node[:home], '.vim') do
  to vimfiles
  user user
end
