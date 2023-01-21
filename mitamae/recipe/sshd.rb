# setup ssh
ssh_port = node[:ssh_port] ||= "22"
package "openssh-server" do
  action :install
end
file '/etc/ssh/sshd_config' do
  action :edit
  block do |content|
    content.gsub!(/#?Port .*/, "Port #{ssh_port}")
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
