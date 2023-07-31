dotfiles_url =  node[:dotfiles_url] ||= "git@github.com:nakahiro386/dotfiles.git"
git_clone File.join(node[:home], 'repo/github.com/nakahiro386/dotfiles') do
  repository dotfiles_url
  user user
end

vimfiles_url =  node[:vimfiles_url] ||= "git@github.com:nakahiro386/vimfiles.git"
vimfiles = File.join(node[:home], 'repo/github.com/nakahiro386/vimfiles')
git_clone "#{vimfiles}" do
  repository vimfiles_url
  user user
end
link File.join(node[:home], '.vim') do
  to vimfiles
  user user
end
