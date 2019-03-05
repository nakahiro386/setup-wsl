# node[:target_user] ||= ENV['SUDO_USER']
node[:target_user] ||= ENV['USER']
user_info = node['user'][node[:target_user]]
p user_info
raise "rootでは実行しない。" if node[:target_user] == "root"

node[:target_group] ||= run_command("id -gn #{node[:target_user]}").stdout.strip!
node[:user_home] ||= user_info['directory']
node[:anyenv_root] ||= "#{node[:user_home]}/.anyenv"

git node[:anyenv_root] do
  repository "https://github.com/anyenv/anyenv"
end

node[:profile] ||= "#{node[:user_home]}/.profile"
file "#{node[:profile]}" do
  action :edit
  block do |content|
    unless content =~ /anyenv init/
      content.concat <<-CONF
# mitamae managed
export PATH="#{node[:anyenv_root]}/bin:$PATH"
eval "$(anyenv init -)"

      CONF
    end
  end
end

execute  "#{node[:anyenv_root]}/bin/anyenv install --force-init" do
  not_if "test -d #{node[:user_home]}/.config/anyenv/anyenv-install"
end

node[:anyenv_plugins_dir] ||= "#{node[:anyenv_root]}/plugins"
node[:anyenv_plugins] ||= %w(anyenv-update anyenv-git)
node[:anyenv_plugins].each do |plugin|
  git "#{node[:anyenv_plugins_dir]}/#{plugin}" do
    repository "https://github.com/znz/#{plugin}.git"
  end
end

node[:anyenv_envs] ||= {
  pyenv: [
    'https://github.com/pyenv/pyenv-doctor.git',
    'https://github.com/pyenv/pyenv-installer.git',
    'https://github.com/pyenv/pyenv-update.git',
    'https://github.com/pyenv/pyenv-virtualenv.git',
    'https://github.com/pyenv/pyenv-which-ext.git'
  ],
  rbenv: [
    'https://github.com/sstephenson/rbenv-default-gems.git',
    'https://github.com/sstephenson/rbenv-gem-rehash.git'
  ]
}

node[:anyenv_envs].each do |env, plugins|
  execute  "#{node[:anyenv_root]}/bin/anyenv install --skip-existing #{env}" do
    not_if "test -d #{node[:anyenv_root]}/envs/#{env}"
  end
  directory "#{node[:anyenv_root]}/envs/#{env}/cache" do
    action :create
  end
  plugins.each do |plugin|
    plugin_name = File.basename(plugin).gsub(/\.git$/, '')
    git "#{node[:anyenv_root]}/envs/#{env}/plugins/#{plugin_name}" do
      repository plugin
    end
  end
end
