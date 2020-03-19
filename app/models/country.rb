class Country < ApplicationRecord
  validates_presence_of :code, :country_name
end
