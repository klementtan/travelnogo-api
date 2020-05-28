class ApplicationController < ActionController::API;
  def health_check
    #Check db connection
    database_connection = false
    require './config/environment.rb' # Assuming the script is located in the root of the rails app
    begin
      ActiveRecord::Base.establish_connection # Establishes connection
      puts 'ActiveRecord::Base.establish_connection Pass!'
      ActiveRecord::Base.connection # Calls connection object
      puts 'ActiveRecord::Base.connection pass'
      database_connection = true if ActiveRecord::Base.connected?
      puts 'ActiveRecord::Base.connected? pass'
    rescue
      puts 'NOT CONNECTED!'
    end

    #Check redis connection
    redis_connection = true
    begin
      puts "Connecting to Redis..."
      REDIS.ping
    rescue
      puts "Error: Redis server unavailable. Shutting down..."
      redis_connection =  false
    end

    render json: {
        redis_connection: redis_connection,
        sever_running: true,
        database_connection: database_connection
    }
  end
end
