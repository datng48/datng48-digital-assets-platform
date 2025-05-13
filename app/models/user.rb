class User < ApplicationRecord
  self.table_name = "digital_assets.users"
  
  class NotAuthorized < StandardError; end

  attr_accessor :password, :password_confirmation

  has_many :assets, dependent: :destroy
  has_many :purchases
  has_many :purchased_assets, through: :purchases, source: :asset

  enum :role, { customer: 0, creator: 1, admin: 2 }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true
  validates :password, presence: true, on: :create
  validates :password, confirmation: true, if: :password_required?

  before_save :encrypt_password, if: :password_required?
  before_create :set_default_earnings

  def authenticate(unencrypted_password)
    BCrypt::Password.new(encrypted_password) == unencrypted_password && self
  end

  def total_earnings
    self[:total_earnings] || 0.00
  end

  def can_purchase?(asset)
    customer? && asset.user_id != id
  end

  def owns?(asset)
    purchases.exists?(asset: asset)
  end

  private

  def encrypt_password
    self.encrypted_password = BCrypt::Password.create(password)
  end

  def password_required?
    encrypted_password.blank? || !password.blank?
  end
  
  def set_default_earnings
    self.total_earnings ||= 0.00
  end
end
