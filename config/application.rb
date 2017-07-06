require_relative 'boot'
require_relative '../app/middleware/rate_limiter'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsRateLimiting
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Inject rate limiting middleware
    config.middleware.use RateLimiter

    # Configure Redis for Rails cache_store
    config.cache_store = :redis_store, {
      host: ENV['REDIS_HOST'],
      port: ENV['REDIS_PORT'],
      db: ENV['REDIS_DATABASE'],
      namespace: ENV['REDIS_NAMESPACE']
    }
  end
end
