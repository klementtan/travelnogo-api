class ApplicationController < ActionController::API;
  rescue_from Exception, with: :render_500_error

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

  def all_api_logs
    render json: ApiQueryLog.all
  end

  def migrate_server
    data = JSON.parse(params['data'])
    i = 1
    data.each do |ban|
      banner = Country.find_by_code(ban['banner']['code'])
      bannee = Country.find_by_code(ban['bannee']['code'])

      ApiQueryLog.create!(response: "#{ban['bannee']['code']} cannot be found") if bannee.nil?

      ApiQueryLog.create!(response: "#{ban['banner']['code']} cannot be found") if banner.nil?
      
      next if bannee.nil? || banner.nil?

      puts i.to_s + '/' + data.length.to_s
      ban_new = Ban.find_by(banner: banner, bannee: bannee)
      next unless ban_new.nil?

      ban_url = ban['ban_url']
      ban_description = ban['ban_description']
      ban_type = ban['ban_type']

      new_ban = Ban.create!(banner: banner, bannee: bannee, ban_url: ban_url, ban_description: ban_description, ban_type: ban_type)
      new_ban.save!

      puts 'Adding new ban for ' + banner.country_name + ' imposing on ' + bannee.country_name
      i = i + 1
    end
    render json: {
        message: "ok"
    }
  end

  def render_500_error(error)
    log_api_call(500, error)
    render json: {error: error.message}, status: 500 # Internal Server Error
  end

  protected
  # API Query Logs are cleared every three months. Look at task_scheduler.rb and XfersDailyCleanupJob
  def log_api_call(status, error = nil)
    resp = error || JSON.parse(response.body) || response.body


    controller = params['controller']
    action = params['action']


    # FIXME: use .to_json rather than .to_s, because there might be some hacks parsing the log
    resp = ensure_within_text_length(resp.to_s)

    api_query_log = ApiQueryLog.create!(
        controller: controller,
        action: action,
        params: params.to_s,
        response: resp,
        status: status,
        )

    return if status == 200

    Rails.logger.info "#{controller}##{action}: #{status} #{error&.inspect}"

    return if status != 500

    # logger.error(error)
    # Rollbar.error(error)
    # title = "HTTP 500 - #{controller}##{action} #{api_query_log.to_finder}"
    # SlackHelper.devops.error resp, title: title
  end

  def ensure_within_text_length(text)
    return nil if text.nil?
    return text if text.length < 65_535

    text[0..65_534]
  end
end
