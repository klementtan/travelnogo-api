# Parent class for all API controllers
class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate
  skip_before_action :authenticate, only: [:update_user_uuid, :helloworld]

  def helloworld
    database_connection = false
    require './config/environment.rb' # Assuming the script is located in the root of the rails app
    begin
      ActiveRecord::Base.establish_connection # Establishes connection
      ActiveRecord::Base.connection # Calls connection object
      database_connection = true if ActiveRecord::Base.connected?
    rescue
      puts "NOT CONNECTED!"
    end

    render json: {
        database_connection: database_connection,
        message: ENV['HELLO_WORLD']
    }
  end

  # def update_user_uuid
  #   user_data = params['user']
  #   user_info_data = user_data['user_info']
  #   @user = User.find_by_email(user_info_data['email'])
  #   raise AuthenticationError, "User #{User['email']} is not a valid admin email" if @user.nil?
  #
  #   @user.firebase_uuid = user_data['firebase_uuid']
  #   @user.name = user_info_data['name']
  #   @user.save!
  #
  #   render json: @user, serializer: UserSerializer
  # end

  def get_user
    render json: @user, serializer: UserSerializer
  end

  def create_admin_user
    raise AuthorizationError, "#{@user.name} is not authorised to execute this task" unless @user.has_role? AuthorizationRoles::SUPER_ADMIN

    new_admin_emails = params['new_admin_email']
    raise InvalidParamsError, 'Parameter new_admin_email empty or invalid' if new_admin_emails.nil? || new_admin_emails.empty?

    new_users = []

    new_admin_emails.each do |email|
      raise InvalidParamsError, "#{email} invalid format" if URI::MailTo::EMAIL_REGEXP.match(email).nil?
      next unless User.find_by_email(email).nil?

      user = User.create!(email: email)
      user.add_role AuthorizationRoles::ADMIN if user.roles.blank?

      new_users.append(user)
    end
    render json: new_users
  end

  def get_all_users
    render json: User.all, each_serializer: UserSerializer


  end
end
