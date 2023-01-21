
node[:target_user] ||= ENV['SUDO_USER']
user_info = node['user'][node[:target_user]]
p user_info

user = node[:target_user]
node[:home] = user_info[:directory]
home = node[:home]

raise "rootでは実行しない。" if user == "root"

include_recipe 'recipe/wsl_conf'

include_recipe 'recipe/sudoers'

include_recipe 'recipe/fixshm'

include_recipe 'recipe/apt_mirrors'
include_recipe 'recipe/apt_ppa_repository'
include_recipe 'recipe/packages'

include_recipe 'recipe/localize'

include_recipe 'recipe/sshd'
include_recipe 'recipe/home'

node[:docker_rootless] ||= {}
node[:docker_rootless][:user] = user
include_recipe 'recipe/docker'
include_recipe 'recipe/docker-rootless'

# vim, vifm
include_recipe 'recipe/appimage'
include_recipe 'recipe/lazygit'
include_recipe 'recipe/git_clone'
