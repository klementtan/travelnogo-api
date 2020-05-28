class BanSerializer < ActiveModel::Serializer
  attributes :id, :banner, :bannee, :ban_description, :ban_type, :ban_url
  def banner
    self.object.banner
  end

  def bannee
    self.object.bannee
  end
end
