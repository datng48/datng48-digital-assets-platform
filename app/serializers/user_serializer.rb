class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :role

  has_many :assets, if: :is_creator?
  has_many :purchased_assets, if: :is_customer?

  def is_creator?
    object.creator?
  end

  def is_customer?
    object.customer?
  end
end 