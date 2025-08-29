require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'validations' do
    it { is_expected.to validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
  end

  describe '#update_summary!' do
    let(:product) { create(:product, price: 20) }
    let(:cart) { create(:cart, items: [build(:cart_item, product: product, quantity: 1)]) }

    it 'updates the cart total price' do
      cart.update_summary!
      expect(cart.total_price).to eq(20)
    end

    it 'updates the cart abandoned status' do
      cart.update_summary!
      expect(cart.abandoned).to eq(false)
    end

    it 'updates the cart last interaction time' do
      cart.update_summary!
      expect(cart.last_interaction_at).to be_present
    end
  end
end
