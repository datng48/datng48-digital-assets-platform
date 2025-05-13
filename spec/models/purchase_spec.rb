require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:asset) }
  end

  describe 'custom validations' do
    let(:creator) { create(:user, :creator) }
    let(:customer) { create(:user) }
    let(:asset) { create(:asset, user: creator) }

    context 'user_cannot_purchase_own_asset' do
      it 'prevents creator from purchasing their own asset' do
        purchase = build(:purchase, user: creator, asset: asset)
        expect(purchase).not_to be_valid
        expect(purchase.errors[:base]).to include('Cannot purchase your own asset')
      end

      it 'allows customer to purchase creator\'s asset' do
        purchase = build(:purchase, user: customer, asset: asset)
        expect(purchase).to be_valid
      end
    end

    context 'user_must_be_customer' do
      it 'prevents creator from making purchases' do
        another_asset = create(:asset, user: create(:user, :creator))
        purchase = build(:purchase, user: creator, asset: another_asset)
        expect(purchase).not_to be_valid
        expect(purchase.errors[:base]).to include('Only customers can make purchases')
      end

      it 'allows customer to make purchases' do
        purchase = build(:purchase, user: customer, asset: asset)
        expect(purchase).to be_valid
      end
    end
  end
end
