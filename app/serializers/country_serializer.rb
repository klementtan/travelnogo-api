class CountrySerializer < ActiveModel::Serializer
  attributes :id, :code, :country_name
end
