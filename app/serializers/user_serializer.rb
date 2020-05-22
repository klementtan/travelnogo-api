class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role
  def role
    return self.object.roles[0].name
  end
end
