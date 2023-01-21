user = node[:target_user]
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

