require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
    it { should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { should have_many(:assets).dependent(:destroy) }
    it { should have_many(:purchases) }
    it { should have_many(:purchased_assets).through(:purchases) }
  end

  describe 'methods' do
    let(:creator) { create(:user, :creator) }
    let(:customer) { create(:user) }
    let(:asset) { create(:asset, user: creator, price: 100) }

    describe '#total_earnings' do
      it 'calculates total earnings from asset purchases' do
        create(:purchase, asset: asset, amount: 100)
        create(:purchase, asset: asset, amount: 50)
        expect(creator.total_earnings).to eq(150)
      end
    end

    describe '#can_purchase?' do
      it 'returns true for customer trying to purchase other creator\'s asset' do
        expect(customer.can_purchase?(asset)).to be true
      end

      it 'returns false for customer trying to purchase own asset' do
        customer_asset = create(:asset, user: customer)
        expect(customer.can_purchase?(customer_asset)).to be false
      end

      it 'returns false for creator trying to purchase asset' do
        another_asset = create(:asset, user: create(:user, :creator))
        expect(creator.can_purchase?(another_asset)).to be false
      end
    end

    describe '#owns?' do
      it 'returns true if user has purchased the asset' do
        purchase = create(:purchase, user: customer, asset: asset)
        expect(customer.owns?(asset)).to be true
      end

      it 'returns false if user has not purchased the asset' do
        expect(customer.owns?(asset)).to be false
      end
    end
  end
end
