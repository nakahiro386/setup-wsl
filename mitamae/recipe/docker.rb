architecture = run_command("dpkg --print-architecture").stdout.chomp
codename = run_command("lsb_release -cs").stdout.chomp

execute "docker.gpg" do
  command <<-"EOH"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  EOH
  not_if "test -f /etc/apt/keyrings/docker.gpg"
end
file '/etc/apt/sources.list.d/docker.list' do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
deb [arch=#{architecture} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu #{codename} stable
  EOH
  notifies :run, "execute[apt update]", :immediately
end
%w(docker-ce docker-ce-cli containerd.io docker-compose-plugin).each do |pkg|
  package pkg do
    action :install
  end
end
