require_relative 'boot'

require "rails"
require 'net/http'

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DashboardBackend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

     # This will allow GET, POST or OPTIONS requests from any origin on any resource.
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    # Configuration for our code
    config.tmc_api_base_address = "https://tmc.mooc.fi/api/v8"

    # Create a short, insecure secret for every new server instance.
    # This is a step up from just using "secret", but still not crypto-
    # graphically secure; in production we'd do this properly.
    six_digit_hex_string = "%06x" % Random::rand(65536 * 256)
    config.jwt_secret = six_digit_hex_string.upcase

    #config.jwt_secret = "secret"

    config.jwt_verify_tmc_credentials = true

    # For badges... Can we move these to another file?
    config.badges = Rails.application.config_for(:badges)

  end
end
