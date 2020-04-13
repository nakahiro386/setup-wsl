
node[:target_user] ||= ENV['SUDO_USER']
user_info = node['user'][node[:target_user]]
p user_info

raise "rootでは実行しない。" if node[:target_user] == "root"

# apt upgrade
file '/etc/apt/sources.list' do
  action :edit
  block do |content|
    content.gsub!(/http:\/\/[^ ]+\/ubuntu\//, "mirror://mirrors.ubuntu.com/mirrors.txt")
  end
  notifies :run, "execute[apt upgrade]", :immediately
end

execute "apt upgrade" do
  command <<-"EOH"
apt update
apt upgrade --auto-remove --assume-yes
EOH
  action :nothing
end

%w(nano).each do |pkg|
  package pkg do
    action :remove
  end
end

# 日本語化
%w(language-pack-ja tzdata manpages-ja manpages-ja-dev).each do |pkg|
  package pkg
end

node[:locale] ||= 'ja_JP.UTF-8'
execute "update-locale" do
  command "update-locale LANG=#{node[:locale]}"
  not_if "locale | grep '#{node[:locale]}'"
end

node[:tz] ||= 'Asia/Tokyo'
execute "update-timezone" do
  command <<-"EOH"
ln -sf /usr/share/zoneinfo/#{node[:tz]} /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata
EOH
  not_if "date | grep 'JST'"
end

# sshの設定
file '/etc/ssh/sshd_config' do
  action :edit
  block do |content|
    content.gsub!(/#?PasswordAuthentication .*/, "PasswordAuthentication yes")
  end
  notifies :run, "execute[dpkg-reconfigure openssh-server]", :immediately
end
execute "dpkg-reconfigure openssh-server" do
  command "dpkg-reconfigure --frontend noninteractive openssh-server"
  action :nothing
end

