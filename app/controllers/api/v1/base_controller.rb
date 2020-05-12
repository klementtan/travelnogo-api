# Parent class for all API controllers
class Api::V1::BaseController < ActionController::Base
  skip_before_action :verify_authenticity_token
  helper_method :authenticate
  # rescue_from Exception, with: :render_500_error
  rescue_from AuthenticationError, with: :render_404_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_404_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_json_error

  def authenticate
    key = params['X_TRAVELNOGO_KEY']
    if key != ENV['X_TRAVELNOGO_KEY']
      raise AuthenticationError, 'Invalid API Key'
    end
  end

  def render_json_error(error)
    render json: {
             error: "#{error.record.class.name} record: #{error.message}"
           },
           status: 400 # Bad Request
  end

  def render_500_error(error)
    render json: { error: error.message }, status: 500 # Internal Server Error
  end

  def render_400_error(error)
    render json: { error: error.message }, status: 400 # Internal Server Error
  end

  def render_401_error(error)
    render json: { error: error.message }, status: 401 # Internal Server Error
  end

  def render_404_error(error)
    render json: { error: error.message }, status: 404 # Not Found
  end
end
