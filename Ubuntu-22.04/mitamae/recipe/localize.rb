default_localize = Hashie::Mash.new({
  packages: %w(language-pack-ja manpages-ja manpages-ja-dev),
  locale: 'ja_JP.UTF-8',
  tz: 'Asia/Tokyo'
})

localize = default_localize.merge(node[:localize] ||= {})

localize[:packages].each do |pkg|
  package pkg
end

locale = localize[:locale]
execute "set-locale" do
  command "localectl set-locale LANG=#{locale}"
  not_if "localectl status | grep 'LANG=#{locale}'"
end

localize[:tz] ||= 'Asia/Tokyo'
execute "update-timezone" do
  command "timedatectl set-timezone #{node[:tz]}"
  not_if "timedatectl status | grep 'Time zone: #{node[:tz]}'"
end

