class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role
  def role
    roles = []
    self.object.roles.each do |curr_role|
      roles.append(curr_role.name)
    end
    return roles
  end
end
