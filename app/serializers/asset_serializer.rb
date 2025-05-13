class AssetSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :file_url, :price, :creator_name

  def creator_name
    object.user.email
  end
end 