node[:target_user] ||= ENV['SUDO_USER']
user_info = node['user'][node[:target_user]]
p user_info
raise "rootでは実行しない。" if node[:target_user] == "root"

node[:packages] ||= <<'EOS'.gsub(/^\s+/, '').gsub(' ', "\n").split("\n")
  git
  curl wget
EOS

# Common build problems · pyenv/pyenv Wiki · GitHub
# https://github.com/pyenv/pyenv/wiki/common-build-problems
node[:packages] = node[:packages] | %w(make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev xz-utils libffi-dev liblzma-dev)

# Home · rbenv/ruby-build Wiki · GitHub
# https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
node[:packages] = node[:packages] | %w(autoconf bison build-essential libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev)

node[:packages].each do |pkg|
  package pkg
end

