class ScraperRequestSerializer < ActiveModel::Serializer
  attributes :id, :date, :source
  has_many :scraper_ban_requests
end
