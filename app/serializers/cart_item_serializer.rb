class CartItemSerializer < ActiveModel::Serializer
  delegate :id, :name, to: :product

  attributes :id, :name, :quantity, :unit_price, :total_price

  private

  def product
    object.product
  end
end
