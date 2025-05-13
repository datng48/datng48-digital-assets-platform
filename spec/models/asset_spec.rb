require 'rails_helper'

RSpec.describe Asset, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:file_url) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:purchases).dependent(:destroy) }
    it { should have_many(:customers).through(:purchases) }
  end

  describe '.bulk_import' do
    let(:creator) { create(:user, :creator) }
    let(:valid_json) do
      [
        {
          title: 'Asset 1',
          description: 'Description 1',
          file_url: 'http://example.com/1',
          price: 10.0
        },
        {
          title: 'Asset 2',
          description: 'Description 2',
          file_url: 'http://example.com/2',
          price: 20.0
        }
      ].to_json
    end

    it 'creates multiple assets from valid JSON' do
      expect {
        Asset.bulk_import(creator, valid_json)
      }.to change(Asset, :count).by(2)
    end

    it 'assigns correct attributes to created assets' do
      assets = Asset.bulk_import(creator, valid_json)
      expect(assets.first.title).to eq('Asset 1')
      expect(assets.second.price).to eq(20.0)
    end

    it 'raises InvalidJsonError for invalid JSON' do
      expect {
        Asset.bulk_import(creator, 'invalid json')
      }.to raise_error(InvalidJsonError)
    end

    it 'raises BulkImportError for invalid asset data' do
      invalid_json = [{ title: nil }].to_json
      expect {
        Asset.bulk_import(creator, invalid_json)
      }.to raise_error(BulkImportError)
    end
  end

  describe '#purchased_by?' do
    let(:asset) { create(:asset) }
    let(:customer) { create(:user) }

    it 'returns true if user has purchased the asset' do
      create(:purchase, user: customer, asset: asset)
      expect(asset.purchased_by?(customer)).to be true
    end

    it 'returns false if user has not purchased the asset' do
      expect(asset.purchased_by?(customer)).to be false
    end
  end
end
