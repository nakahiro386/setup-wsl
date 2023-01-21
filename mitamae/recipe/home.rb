directory File.join(node[:home], ".ssh") do
  action :create
  user user
  owner user
  group user
  mode "700"
end

directory File.join(node[:home], "bin") do
  action :create
  user user
  owner user
  group user
end
