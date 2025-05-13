class PurchaseSerializer < ActiveModel::Serializer
  attributes :id, :amount, :created_at, :asset_id, :asset_info
  
  belongs_to :asset
  belongs_to :user
  
  def asset_info
    {
      id: object.asset.id,
      title: object.asset.title,
      price: object.asset.price,
      file_url: object.asset.file_url
    }
  end
end 