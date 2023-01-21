git_protocol =  node[:git_protocol] ||= "git@"
git_clone File.join(node[:home], 'repo/github.com/nakahiro386/dotfiles') do
  repository "#{git_protocol}github.com:nakahiro386/dotfiles.git"
  user user
end

vimfiles = File.join(node[:home], 'repo/github.com/nakahiro386/vimfiles')
git_clone "#{vimfiles}" do
  repository "#{git_protocol}github.com:nakahiro386/vimfiles.git"
  user user
end
link File.join(node[:home], '.vim') do
  to vimfiles
  user user
end
