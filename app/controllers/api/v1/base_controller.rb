# Parent class for all API controllers
class Api::V1::BaseController < ActionController::Base
  skip_before_action :verify_authenticity_token
  helper_method :authenticate, :decode_firebase_token, :authenticate_internal, :send_slack_message
  rescue_from Exception, with: :render_500_error
  rescue_from AuthenticationError, with: :render_403_error
  rescue_from AuthorizationError, with: :render_403_error
  rescue_from InvalidParamsError, with: :render_400_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_404_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_json_error

  def decode_firebase_token(request)
    FirebaseIdToken::Certificates.request
    jwt_token = request.headers['Authorization']
    raise AuthenticationError, 'Bearer Token empty' if jwt_token.nil?

    jwt_token.slice!('Bearer ')
    firebase_user_json = FirebaseIdToken::Signature.verify(jwt_token)

    raise AuthenticationError, 'Invalid token' if firebase_user_json.nil?

    return firebase_user_json
  end

  def authenticate
    firebase_user_json = decode_firebase_token(request)
    @user = User.find_by_firebase_uuid(firebase_user_json['sub'])
    if @user.nil?
      @user = User.find_by_email(firebase_user_json['email'])
      raise AuthenticationError, "#{firebase_user_json["email"]} does not belong to a valid user or has not been created" if @user.nil?

      @user.firebase_uuid = firebase_user_json['sub']
      @user.name = firebase_user_json['name']
      @user.save!
    end
  end

  def authenticate_internal
    raise AuthenticationError, 'Invallid token' if  request.headers['X-TRAVELNOGO-KEY'] != ENV['X_TRAVELNOGO_KEY']
  end

  def render_json_error(error)
    log_api_call(400, error)
    render json: {
      error: "#{error.record.class.name} record: #{error.message}"
    },
           status: 400 # Bad Request
  end

  def render_500_error(error)
    log_api_call(500, error)
    render json: {error: error.message}, status: 500 # Internal Server Error
  end

  def render_400_error(error)
    log_api_call(400, error)
    render json: {error: error.message}, status: 400 # Internal Server Error
  end

  def render_401_error(error)
    log_api_call(401, error)
    render json: {error: error.message}, status: 401 # Internal Server Error
  end

  def render_403_error(error)
    log_api_call(403, error)
    render json: {error: error.message}, status: 403 #Authentication Error
  end

  def render_404_error(error)
    log_api_call(404, error)
    render json: {error: error.message}, status: 404 # Not Found
  end

  def send_slack_message(message)
    body = {
      "text": message
    }
    HTTParty.post(ENV['SLACK_URL'],
                  {
                    body: body.to_json,
                    headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
                  })
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

