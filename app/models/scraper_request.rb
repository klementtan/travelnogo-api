class ScraperRequest < ApplicationRecord
  has_many :scraper_ban_requests
  validates_presence_of :source, :date
end
