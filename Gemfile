source 'https://rubygems.org'

gem 'jekyll', '~> 4.2.0'
gem 'minima', '~> 2.5'

group :jekyll_plugins do
  gem 'jekyll-feed', '~> 0.15'
  gem 'jekyll-seo-tag', '~> 2.7'
  gem 'jekyll-sitemap', '~> 1.4'
end

# Windows and JRuby do not include zoneinfo files, so bundle the tzinfo-data
# gem and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem 'tzinfo', '~> 1.2'
  gem 'tzinfo-data'
end

# Performance-booster for watching directories on Windows
gem 'wdm', '~> 0.1.1', :install_if => Gem.win_platform?

# Install eventmachine from Git. The latest gem doesn't work with Ruby on Windows (5/10/21).
# https://github.com/oneclick/rubyinstaller2/issues/96
# https://stackoverflow.com/questions/30682575/unable-to-load-the-eventmachine-c-extension-to-use-the-pure-ruby-reactor
gem 'eventmachine', '1.2.7', git: 'https://github.com/eventmachine/eventmachine.git', tag: 'v1.2.7'
