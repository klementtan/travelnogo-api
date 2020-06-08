# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.logger = Logger.new(STDOUT)
Rails.application.config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")

Rails.application.config.cache_store = :redis_store, {
    expires_in: 1.hour,
    namespace: 'cache',
    redis: REDIS,
}