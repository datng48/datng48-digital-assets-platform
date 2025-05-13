class PurchaseSerializer < ActiveModel::Serializer
  attributes :id, :amount, :created_at, :asset_id
  
  belongs_to :asset
  belongs_to :user
end 