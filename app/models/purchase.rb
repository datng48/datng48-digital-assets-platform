class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :asset

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :user_cannot_purchase_own_asset
  validate :user_must_be_customer

  after_create :update_creator_earnings

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

  def update_creator_earnings
    creator = asset.user
    creator.increment!(:total_earnings, amount)
  end
end
