class User < ApplicationRecord
  after_create :assign_default_role
  rolify

  def assign_default_role
    self.add_role(AuthorizationRoles::ADMIN) if self.roles.blank?
  end
end
