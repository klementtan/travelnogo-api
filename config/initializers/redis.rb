REDIS = Redis.new(url: ENV['REDIS_URL'])



FirebaseIdToken.configure do |config|
  config.redis = REDIS
end