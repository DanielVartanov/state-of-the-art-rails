source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails"
gem "propshaft"
gem "pg"
gem "puma"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "solid_cable"
gem "bootsnap", require: false
gem "haml-rails"
gem "bootstrap_form"

group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "debug"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
  gem "haml_lint", require: false
  gem "brakeman", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "rspec-its"
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "rspec-rails"
  gem "super_diff"
end
