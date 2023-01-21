user = node[:target_user]
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
