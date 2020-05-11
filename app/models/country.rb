class Country < ApplicationRecord
  has_many :ban, foreign_key: "user_id", class_name: "Task"
  validates_presence_of :code, :country_name
end
