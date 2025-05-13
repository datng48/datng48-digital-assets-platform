class Purchase < ApplicationRecord
  self.table_name = "digital_assets.purchases"
  
  belongs_to :user
  belongs_to :asset

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :user_cannot_purchase_own_asset
  validate :user_must_be_customer
  validate :no_duplicate_purchase

  private

  def user_cannot_purchase_own_asset
    return unless user && asset
    if user_id == asset.user_id
      errors.add(:base, "Cannot purchase your own asset")
    end
  end

  def user_must_be_customer
    return unless user
    unless user.customer?
      errors.add(:base, "Only customers can make purchases")
    end
  end

  def no_duplicate_purchase
    return unless user && asset
    if Purchase.where(user_id: user_id, asset_id: asset_id).exists?
      errors.add(:base, "You have already purchased this asset")
    end
  end
end
