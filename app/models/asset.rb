class Asset < ApplicationRecord
  self.table_name = "digital_assets.assets"
  
  belongs_to :user
  has_many :purchases, dependent: :destroy
  has_many :customers, through: :purchases, source: :user

  validates :title, presence: true
  validates :description, presence: true
  validates :file_url, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.bulk_import(user, json_data)
    assets_data = json_data.is_a?(String) ? JSON.parse(json_data) : json_data
    
    Asset.transaction do
      assets_data.map do |asset_data|
        user.assets.create!(
          title: asset_data['title'],
          description: asset_data['description'],
          file_url: asset_data['file_url'],
          price: asset_data['price']
        )
      end
    end
  rescue JSON::ParserError => e
    raise InvalidJsonError, "Invalid JSON format: #{e.message}"
  rescue ActiveRecord::RecordInvalid => e
    raise BulkImportError, "Invalid asset data: #{e.message}"
  end

  def purchased_by?(user)
    purchases.exists?(user: user)
  end
end

class InvalidJsonError < StandardError; end
class BulkImportError < StandardError; end
