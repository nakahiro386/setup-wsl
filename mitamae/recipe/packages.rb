node[:present_packages].each do |pkg|
  package pkg
end
node[:absent_packages].each do |pkg|
  package pkg do
    action :remove
  end
end
