# Parent class for all API controllers
class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate
  skip_before_action :authenticate, only: [:update_user_uuid]

  def update_user_uuid
    firebase_user_json = decode_firebase_token(request)
    firebase_uuid =firebase_user_json["sub"]
    user_email = firebase_user_json["email"]
    user = User.find_by_email(user_email)
    raise AuthenticationError, "#{user_email} does not belong to a valid user" if user.nil?
    user.firebase_uuid = firebase_uuid
    user.name = firebase_user_json["name"]
    user.save
    render json: user
  end

  def create_admin_user
    raise AuthorizationError, "#{@user.name} is not auathorized to execute this task" unless @user.has_role? AuthorizationRoles::SUPER_ADMIN
    new_admin_emails = params["new_admin_email"]
    raise InvalidParamsError, "Parameter new_admin_email empty or invalid" if new_admin_emails.nil? || new_admin_emails.empty?

    new_users = []

    new_admin_emails.each do |email|
      raise InvalidParamsError, "#{email} invalid format" if URI::MailTo::EMAIL_REGEXP.match(email).nil?
      next unless User.find_by_email(email).nil?
      user = User.create!(email: email)
      new_users.append(user)
    end

    render json: new_users

  end
end
