# node[:target_user] ||= ENV['SUDO_USER']
node[:target_user] ||= ENV['USER']
user_info = node['user'][node[:target_user]]
p user_info
raise "rootでは実行しない。" if node[:target_user] == "root"

node[:target_group] ||= run_command("id -gn #{node[:target_user]}").stdout.strip!
node[:user_home] ||= user_info['directory']
node[:anyenv_root] ||= "#{node[:user_home]}/.anyenv"

directory "#{node[:user_home]}/.local" do
  action :create
  mode "700"
end
directory "#{node[:user_home]}/.local/bin" do
  action :create
  mode "775"
end

git node[:anyenv_root] do
  repository "https://github.com/anyenv/anyenv"
  not_if "test -d #{node[:anyenv_root]}"
end

node[:profile] ||= "#{node[:user_home]}/.profile"
file "#{node[:profile]}" do
  action :edit
  block do |content|
    unless content =~ /ANYENV_ROOT/
      content.concat <<-CONF
# mitamae managed
if [ -x "#{node[:anyenv_root]}/bin/anyenv" ] ; then
    export ANYENV_ROOT=#{node[:anyenv_root]};
    export PATH="$ANYENV_ROOT/bin:$PATH"
    if [ -r "#{node[:user_home]}/.anyenv_init" ] ; then
        source "#{node[:user_home]}/.anyenv_init"
    else
        anyenv init - bash --no-rehash > "#{node[:user_home]}/.anyenv_init"
        eval "$(anyenv init - bash)"
    fi
fi
export PIPENV_VENV_IN_PROJECT=true
      CONF
    end
  end
end

execute  "#{node[:anyenv_root]}/bin/anyenv install --force-init" do
  not_if "test -d #{node[:user_home]}/.config/anyenv/anyenv-install"
end

node[:anyenv_plugins_dir] ||= "#{node[:anyenv_root]}/plugins"
node[:anyenv_plugins] ||= [
  'https://github.com/znz/anyenv-update.git',
  'https://github.com/znz/anyenv-git.git',
]
node[:anyenv_plugins].each do |plugin|
  plugin_name = File.basename(plugin).gsub(/\.git$/, '')
  plugin_dir = "#{node[:anyenv_plugins_dir]}/#{plugin_name}"
  git plugin_dir do
    repository plugin
    not_if "test -d #{plugin_dir}"
  end
end

node[:anyenv_envs] ||= {
  pyenv: {
    'plugins': [
      'https://github.com/momo-lab/xxenv-latest.git',
      'https://github.com/pyenv/pyenv-doctor.git',
      'https://github.com/pyenv/pyenv-installer.git',
      'https://github.com/pyenv/pyenv-update.git',
      'https://github.com/pyenv/pyenv-virtualenv.git',
      'https://github.com/pyenv/pyenv-which-ext.git'
    ],
    'versions': [
      '3.7.2'
    ],
    'global': '3.7.2'
  },
  rbenv: {
    'plugins': [
      'https://github.com/momo-lab/xxenv-latest.git',
      'https://github.com/sstephenson/rbenv-default-gems.git',
      'https://github.com/sstephenson/rbenv-gem-rehash.git'
    ],
    'versions': [
    ]
  }
}

node[:anyenv_envs].each do |env, options|
  env_root = "#{node[:anyenv_root]}/envs/#{env}"
  execute  "#{node[:anyenv_root]}/bin/anyenv install --skip-existing #{env}" do
    not_if "test -d #{env_root}"
  end
  directory "#{env_root}/cache" do
    action :create
  end
  options['plugins'].each do |plugin|
    plugin_name = File.basename(plugin).gsub(/\.git$/, '')
    plugin_dir = "#{node[:anyenv_root]}/envs/#{env}/plugins/#{plugin_name}"
    git plugin_dir do
      repository plugin
      not_if "test -d #{plugin_dir}"
    end
  end
  options['versions'].each do |version|
    execute  "#{env_root}/bin/#{env} install --skip-existing #{version}" do
      not_if "test -d #{env_root}/versions/#{version}"
    end
  end
  global = options['global']
  if global
    execute  "#{env_root}/bin/#{env} global #{global}" do
      not_if "#{env_root}/bin/#{env} global | grep #{global}"
    end
  end
end

