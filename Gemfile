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
gem 'bootstrap'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'puts_debuggerer'
  gem 'byebug'
  gem 'parallel_tests'
end

group :development do
  gem 'web-console'
  gem 'rack-mini-profiler'
  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
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
