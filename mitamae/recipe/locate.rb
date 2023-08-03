# setup locate
package "locate" do
  action :install
end

user = node[:target_user]
file "/etc/updatedb.findutils.cron.local" do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
# /etc/cron.daily/locate
FINDOPTIONS="${FINDOPTIONS} -type d -name .git -prune -o"
FINDOPTIONS="${FINDOPTIONS} -type d -name .cache -prune -o"
FINDOPTIONS="${FINDOPTIONS} -type d -name .venv -prune -o"
PRUNEFS="${PRUNEFS} drvfs 9p fuse.sshfs"
LOCALUSER="#{user}"
PRUNEPATHS="${PRUNEPATHS} /home/#{user}/.local/pipx /home/#{user}/.local/share/vimrc/bk"
  EOH
end
