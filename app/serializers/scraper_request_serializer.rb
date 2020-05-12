class ScraperRequestSerializer < ActiveModel::Serializer
  attributes :id, :date, :source
  has_many :scraper_ban_requests

  def date
    self.object.date.strftime('%d.%m.%Y')
  end
end
