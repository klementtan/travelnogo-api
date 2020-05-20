# Parent class for all API controllers
class Api::V1::BaseController < ActionController::Base
  skip_before_action :verify_authenticity_token
  helper_method :authenticate, :decode_firebase_token
  rescue_from Exception, with: :render_500_error
  rescue_from AuthenticationError, with: :render_404_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_404_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_json_error

  def decode_firebase_token(request)
    jwt_token = request.headers['Authorization']
    jwt_token.slice!("Bearer ")
    firebase_user_json = FirebaseIdToken::Signature.verify(jwt_token)
    raise AuthenticationError, "Invalid token" if firebase_user_json.nil?
    return firebase_user_json
  end

  def authenticate
    firebase_user_json = decode_firebase_token(request)
    @user = User.find_by_firebase_uuid(firebase_user_json["sub"])
    raise AuthenticationError, "#{firebase_user_json["email"]} does not belong to a valid user or has not been created" if @user.nil?
  end

  def render_json_error(error)
    render json: {
        error: "#{error.record.class.name} record: #{error.message}"
    },
           status: 400 # Bad Request
  end

  def render_500_error(error)
    render json: {error: error.message}, status: 500 # Internal Server Error
  end

  def render_400_error(error)
    render json: {error: error.message}, status: 400 # Internal Server Error
  end

  def render_401_error(error)
    render json: {error: error.message}, status: 401 # Internal Server Error
  end

  def render_403_error(error)
    render json: {error: error.message}, status: 403 #Authentication Error
  end

  def render_404_error(error)
    render json: {error: error.message}, status: 404 # Not Found
  end
end
