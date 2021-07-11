source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'rails'
gem 'pg'
gem 'puma'
gem 'sass-rails'
gem 'webpacker', '~> 5.0'
gem 'turbo-rails'
gem 'jbuilder'
gem 'redis'
gem 'bootsnap', require: false
gem 'haml-rails'

group :development, :test do
  gem 'break'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'puts_debuggerer'
  gem 'rspec-rails'
end

group :development do
  gem 'web-console'
  gem 'rack-mini-profiler'
  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'rexml'
  gem 'rspec-its'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
end
