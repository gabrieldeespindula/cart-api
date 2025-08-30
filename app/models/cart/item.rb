class Cart::Item < ApplicationRecord
  belongs_to :cart, touch: :last_interaction_at
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  before_save :copy_product_price

  after_save :update_cart_summary
  after_destroy :update_cart_summary

  private

  def copy_product_price
    self.unit_price = product.price
    self.total_price = product.price * quantity
  end

  def update_cart_summary
    cart.update_summary!
  end
end
