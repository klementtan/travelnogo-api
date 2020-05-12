class ScraperBanRequestSerializer < ActiveModel::Serializer
  attributes :id, :ban_description, :published_date, :banner, :bannee, :status
  def published_date
    self.object.published_date.strftime('%d.%m.%Y')
  end
end
