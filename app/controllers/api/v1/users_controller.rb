# Parent class for all API controllers
class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate

  def check_valid_email
    email = params['email']
    user = User.find_by_email(email)
    raise AuthenticationError, 'Invlaid email address' if user.nil?

    render json: {
        message: `#{email} is valid`
    }
  end

  def get_user
    render json: @user, serializer: UserSerializer
  end

  def create_admin_user
    raise AuthorizationError, "#{@user.name} is not authorised to execute this task" unless @user.has_role? AuthorizationRoles::SUPER_ADMIN

    new_admins = params['new_admins']
    raise InvalidParamsError, 'Parameter new_admins empty or invalid' if new_admins.nil? || new_admins.empty?

    new_admin_object = []

    new_admins.each do |new_admin|
      email = new_admin["email"]
      role = new_admin["role"].to_sym
      raise InvalidParamsError, "Invalid role #{role.to_s}" if role != AuthorizationRoles::SUPER_ADMIN && role != AuthorizationRoles::ADMIN

      raise InvalidParamsError, "#{email} invalid format" if URI::MailTo::EMAIL_REGEXP.match(email).nil?

      unless User.find_by_email(email).nil?
        user = User.find_by_email(email)
        next if user.has_role? role

        user.roles.delete_all
        user.add_role role
        user.save
        new_admin_object.append(user)
        next
      end

      user = User.create!(email: email)
      user.add_role role if user.roles.blank?
      user.save

      new_admin_object.append(user)
    end
    render json: new_admin_object
  end

  def get_all_users
    render json: User.all, each_serializer: UserSerializer


  end
end
