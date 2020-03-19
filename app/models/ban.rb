class Ban < ApplicationRecord
  belongs_to :banner, class_name: "Country"
  belongs_to :bannee, class_name: "Country"
  validates_presence_of :ban_type, :ban_description
end
