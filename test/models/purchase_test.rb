require 'test_helper'

class PurchaseTest < ActiveSupport::TestCase
  def setup
    @creator = User.create!(
      email: 'creator@test.com',
      password: 'password123',
      name: 'Creator',
      role: 'creator'
    )
    
    @customer = User.create!(
      email: 'customer@test.com',
      password: 'password123',
      name: 'Customer',
      role: 'customer'
    )
    
    @asset = Asset.create!(
      title: 'Test Asset',
      description: 'Test Description',
      price: 100,
      file_url: 'https://example.com/test.pdf',
      user: @creator
    )
  end

  test "creator earnings increase with purchases" do
    assert_equal 0, Purchase.joins(:asset)
                           .where(assets: { user_id: @creator.id })
                           .sum(:amount)

    # Create a purchase
    purchase = Purchase.create!(
      user: @customer,
      asset: @asset,
      amount: @asset.price
    )

    # Verify earnings increased
    assert_equal @asset.price, Purchase.joins(:asset)
                                     .where(assets: { user_id: @creator.id })
                                     .sum(:amount)
  end
end 