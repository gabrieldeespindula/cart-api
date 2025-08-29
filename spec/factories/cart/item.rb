FactoryBot.define do
  factory :cart_item, class: 'Cart::Item' do
    cart
    product
    quantity { Faker::Number.between(from: 1, to: 5) }
    unit_price { product.price }
    total_price { quantity * unit_price }
  end
end
