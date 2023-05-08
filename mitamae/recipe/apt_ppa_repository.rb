if node[:platform_version].to_i < 22
  node[:apt_ppa_repository].each do |repo|
    execute "add-apt-repository ppa:#{repo}" do
      command "add-apt-repository -y ppa:#{repo}"
      not_if %Q! grep -e ^deb /etc/apt/sources.list /etc/apt/sources.list.d/*.list| grep -o -E "deb +http://ppa.launchpad.net/#{repo}"!
    end
  end
else
  node[:apt_ppa_repository].each do |repo|
    execute "add-apt-repository ppa:#{repo}" do
      command "add-apt-repository -y -P ppa:#{repo}"
      not_if %Q!add-apt-repository -L | grep -o -E "deb +https://ppa.launchpadcontent.net/#{repo}"!
    end
  end
end
