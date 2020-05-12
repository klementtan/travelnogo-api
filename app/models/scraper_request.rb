class ScraperRequest < ApplicationRecord
  has_many :scraper_ban_requests, :dependent => :destroy
  validates_presence_of :source, :date
end
