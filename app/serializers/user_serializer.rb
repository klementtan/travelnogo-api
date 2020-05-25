class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role
  def role
    object.roles[0].name unless object.roles.empty?
  end
end
