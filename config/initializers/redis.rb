
redis_host = ENV['REDIS_HOST'] || 'localhost'
redis_port = ENV['REDIS_PORT'] || 6379

# The constant below will represent ONE connection, present globally in models, controllers, views etc for the instance. No need to do Redis.new everytime
REDIS = nil
if ENV['production']
  REDIS  = Redis.new(url: ENV['REDIS_URL'])
else
  REDIS = Redis.new(host: redis_host, port: redis_port.to_i)
end


FirebaseIdToken.configure do |config|
  config.redis = REDIS
end