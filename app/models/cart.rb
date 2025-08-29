class Cart < ApplicationRecord
  has_many :items, class_name: 'Cart::Item', dependent: :destroy

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def update_summary!
    total_price = items.reload.sum(&:total_price)

    update!(
      total_price: total_price,
      abandoned: false,
      last_interaction_at: Time.current
    )
  end
end
