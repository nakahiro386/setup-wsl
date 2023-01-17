# setup ssh
package "openssh-server" do
  action :install
end
file '/etc/ssh/sshd_config' do
  action :edit
  block do |content|
    content.gsub!(/#?Port .*/, "Port 2204")
    content.gsub!(/#?PasswordAuthentication .*/, "PasswordAuthentication yes")
  end
  notifies :run, "execute[dpkg-reconfigure openssh-server]", :immediately
end
service "ssh.service" do
  action [:enable, :start]
end
execute "dpkg-reconfigure openssh-server" do
  command "dpkg-reconfigure --frontend noninteractive openssh-server"
  action :nothing
end
