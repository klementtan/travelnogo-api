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
    FirebaseIdToken::Certificates.request!
    begin
      puts 'Connecting to Redis...'
      REDIS.ping
    rescue
      puts 'Error: Redis server unavailable. Shutting down...'
      redis_connection =  false
    end

    render json: {
      firebase_cert: FirebaseIdToken::Certificates.present?,
      redis_connection: redis_connection,
      sever_running: true,
      database_connection: database_connection
    }
  end

  def migrate_server
    data = JSON.parse(params['data'])
    i = 1
    data.each do |ban|

      banner = Country.find_by_code(ban['banner']['code'])
      bannee = Country.find_by_code(ban['banner']['code'])
      puts i.to_s + '/' + data.length.to_s
      ban_new = Ban.find_by(banner: banner, bannee: bannee)
      next unless ban_new.nil?

      ban_url = ban['ban_url']
      ban_description = ban['ban_description']
      ban_type = ban['ban_type']

      new_ban = Ban.create!(banner: banner, bannee: bannee, ban_url: ban_url, ban_description: ban_description, ban_type: ban_type)
      new_ban.save!

      puts 'Adding new ban for ' + banner.country_name + ' imposing on ' + bannee.country_name

      render json: {
          message: "ok"
      }

    end
  end
end
