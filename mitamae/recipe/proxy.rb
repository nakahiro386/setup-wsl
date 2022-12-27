
node[:target_user] ||= ENV['SUDO_USER']
user_info = node['user'][node[:target_user]]
p user_info

ftp_proxy = node['proxy']['ftp_proxy']
http_proxy = node['proxy']['http_proxy']
https_proxy = node['proxy']['https_proxy']
no_proxy = node['proxy']['no_proxy']

raise "rootでは実行しない。" if node[:target_user] == "root"

file "/exc/profile.d/proxy.sh" do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
export FTP_PROXY=#{ftp_proxy}
export ftp_proxy=#{ftp_proxy}
export HTTP_PROXY=#{http_proxy}
export http_proxy=#{http_proxy}
export HTTPS_PROXY=#{https_proxy}
export https_proxy=#{https_proxy}
export NO_PROXY=#{no_proxy}
export no_proxy=#{no_proxy}
  EOH
end

file "/etc/apt/apt.conf.d/95proxy" do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
Acquire::ftp::Proxy "#{ftp_proxy}";
Acquire::http::Proxy "#{http_proxy}";
Acquire::https::Proxy "#{https_proxy}";
  EOH
end

file "/etc/sudoers.d/proxy" do
  action :create
  owner "root"
  group "root"
  mode "440"
  content <<-"EOH"
Defaults env_keep += "FTP_PROXY HTTP_PROXY HTTPS_PROXY NO_PROXY"
Defaults env_keep += "ftp_proxy http_proxy https_proxy no_proxy"
  EOH
end


