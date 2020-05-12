class ScraperBanRequest < ApplicationRecord
  belongs_to :scraper_request
  belongs_to :banner, class_name: 'Country'
  belongs_to :bannee, class_name: 'Country'

  validates_presence_of :ban_description, :published_date
end
