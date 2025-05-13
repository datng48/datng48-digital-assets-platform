class User < ApplicationRecord
  class NotAuthorized < StandardError; end

  has_secure_password

  has_many :assets, dependent: :destroy
  has_many :purchases
  has_many :purchased_assets, through: :purchases, source: :asset

  enum :role, { customer: 0, creator: 1, admin: 2 }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true

  def total_earnings
    assets.joins(:purchases).sum('purchases.amount')
  end

  def can_purchase?(asset)
    customer? && asset.user_id != id
  end

  def owns?(asset)
    purchases.exists?(asset: asset)
  end
end
