require "cucumber/rails"
require "capybara/cuprite"

World(FactoryBot::Syntax::Methods)

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1280, 800], headless: true)
end

Capybara.default_driver    = :cuprite
Capybara.javascript_driver = :cuprite

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :truncation
Cucumber::Rails::Database.javascript_strategy = :truncation
