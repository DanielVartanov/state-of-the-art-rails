source 'https://rubygems.org'

gem 'rails', '~> 8.1'
gem 'propshaft'
gem 'sqlite3'
gem 'puma', '>= 5.0'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder'
gem 'solid_cache'
gem 'solid_queue'
gem 'solid_cable'
gem 'bootsnap', require: false
gem 'kamal', require: false
gem 'thruster', require: false
gem 'image_processing', '~> 1.2'
gem 'rack-attack'
gem 'haml-rails'
gem 'strong_migrations'
gem 'bcrypt'
# Prevent Rails from auto-loading app/ code when running database migrations
gem 'good_migrations'

group :development, :test do
  # Detect inconsistencies between database schema and application models [https://github.com/djezzzl/database_consistency]
  gem 'database_consistency', require: false
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'
  gem 'puts_debuggerer'
  gem 'bundler-audit', require: false
  gem 'brakeman', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'haml_lint', require: false
end

group :development do
  gem 'web-console'
  gem 'annotaterb'
end

group :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'super_diff'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner-active_record'
end
