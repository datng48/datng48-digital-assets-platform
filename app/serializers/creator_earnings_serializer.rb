class CreatorEarningsSerializer < ActiveModel::Serializer
  attributes :creator_id, :name, :total_earnings

  def creator_id
    object.creator_id
  end

  def name
    object.name
  end

  def total_earnings
    object.total_earnings
  end
end 