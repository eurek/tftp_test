require_relative "boot"

require "rails/all"
require_relative "../lib/i18n/backend/active_record"
require_relative "../lib/ext/float"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TimePlanet
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
    config.i18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:fr, :en, :it, :es, :de, :pl]
    config.i18n.fallbacks = [:en, :fr]

    config.action_mailer.deliver_later_queue_name = :mailers

    config.exceptions_app = routes

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.view_specs false
      g.controller_specs false
      g.helper_specs false
      g.helper false
      g.assets false
      g.stylesheets false
      g.javascripts false
    end

    config.add_autoload_paths_to_load_path = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.assets.paths << "#{Rails.root}/app/assets/videos"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #

    # https://docs.forestadmin.com/documentation/how-tos/setup/configuring-cors-headers
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "app.forestadmin.com"
        resource "*", headers: :any, methods: :any,
          expose: ["Content-Disposition"],
          credentials: true
      end
    end
  end
end
