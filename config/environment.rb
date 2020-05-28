# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
Rails.application.configure do
  config.cache_store = :redis_cache_store, { url: "redis://localhost:6379/0" }
end