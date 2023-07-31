
node[:target_user] ||= ENV['USER']
user_info = node['user'][node[:target_user]]
p user_info

user = node[:target_user]
node[:home] = user_info[:directory]
home = node[:home]


include_recipe 'recipe/home'

# vim, vifm
include_recipe 'recipe/appimage'
include_recipe 'recipe/lazygit'
include_recipe 'recipe/git_clone'
include_recipe 'recipe/vim'
