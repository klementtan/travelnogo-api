class BanSerializer < ActiveModel::Serializer
  attributes :id, :banner, :bannee
  def banner
    self.object.banner
  end

  def bannee
    self.object.bannee
  end
end
