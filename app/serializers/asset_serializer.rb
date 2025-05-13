class AssetSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :file_url, :price, :creator_name, :purchased

  def creator_name
    object.user.email
  end

  def purchased
    return false unless scope && scope.customer?
    object.purchased_by?(scope)
  end
end 