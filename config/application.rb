require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StateOfTheArtRails
  class Application < Rails::Application
    config.load_defaults 8.0

    # Autoload lib/ directory (excluding assets and tasks)
    config.autoload_lib(ignore: %w[assets tasks])

    # Tag all SQL queries with the controller/action/job that initiated them
    config.active_record.query_log_tags_enabled = true
  end
end
