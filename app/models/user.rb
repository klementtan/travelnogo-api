class User < ApplicationRecord
  # after_create :assign_default_role
  # has_many :bans, :dependent => :nullify
  validates_presence_of :email
  validates_uniqueness_of :email
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  rolify

  def assign_default_role
    self.add_role(AuthorizationRoles::ADMIN) if self.roles.blank?
  end
end
