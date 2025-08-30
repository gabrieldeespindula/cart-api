class CartSerializer < ActiveModel::Serializer
  attributes :id, :total_price

  has_many :items, key: :products, serializer: CartItemSerializer
end
