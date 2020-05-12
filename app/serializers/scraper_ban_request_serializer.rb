class ScraperBanRequestSerializer < ActiveModel::Serializer
  attributes :id, :ban_description, :published_date, :banner, :bannee
end
