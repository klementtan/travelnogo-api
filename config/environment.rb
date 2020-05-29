# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.logger = Logger.new(STDOUT)
Rails.application.config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")