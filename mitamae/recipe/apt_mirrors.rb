# node[:apt_mirror] ||= "mirror://mirrors.ubuntu.com/mirrors.txt"
node[:apt_mirror] ||= "http://jp.archive.ubuntu.com/ubuntu/"
file '/etc/apt/sources.list' do
  action :edit
  block do |content|
    content.gsub!(/http:\/\/[^ ]*archive.ubuntu.com\/ubuntu\//, node[:apt_mirror])
  end
  notifies :run, "execute[apt update]", :immediately
end
execute "apt update" do
  command <<-"EOH"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
  EOH
  action :nothing
end

