class CountrySerializer < ActiveModel::Serializer
  attributes :id, :code, :country_name, :all_countries
end
