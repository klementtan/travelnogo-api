# Parent class for all API controllers
class ApplicationController < ActionController::API

  def check
    render json: {
      message: 'ok'
    }

  end


end

