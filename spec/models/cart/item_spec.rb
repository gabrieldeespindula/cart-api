require 'rails_helper'

RSpec.describe Cart::Item, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cart).required }
    it { is_expected.to belong_to(:product).required }
  end

  describe 'callbacks' do
    describe '#update_cart_summary' do
      before do
        travel_to Time.parse('2023-01-08 19:28:00 -0300')
      end

      let(:cart) { create(:cart, abandoned: true, last_interaction_at: 1.minute.ago) }
      let(:product) { create(:product, price: 20) }

      context 'when creating a cart item' do
        it 'updates cart summary' do
          cart_item = build(:cart_item, cart:, product: product, quantity: 1)

          cart_item.save!

          cart.reload

          expect(cart.last_interaction_at).to eql(Time.current)
          expect(cart.total_price).to eq(20)
          expect(cart.abandoned).to eql(false)
        end
      end

      context 'when updating a cart item' do
        it 'updates cart summary' do
          cart_item = create(:cart_item, cart:, product: product, quantity: 1)

          cart.update(abandoned: true, last_interaction_at: 1.minute.ago, total_price: 0)

          cart_item.update!(quantity: 3)

          cart.reload

          expect(cart.last_interaction_at).to eql(Time.current)
          expect(cart.total_price).to eq(60)
          expect(cart.abandoned).to eql(false)
        end
      end

      context 'when destroying a cart item' do
        it 'updates cart summary' do
          cart_item = create(:cart_item, cart:, product: product, quantity: 1)
          cart.update(abandoned: true, last_interaction_at: 1.minute.ago)

          cart_item.destroy!

          cart.reload

          expect(cart.last_interaction_at).to eql(Time.current)
          expect(cart.total_price).to eq(0)
          expect(cart.abandoned).to eql(false)
        end
      end
    end

    describe '#set_total_price' do
      let(:product) { create(:product, price: 20) }

      context 'when creating a cart item' do
        it 'sets the total price' do
          cart_item = build(:cart_item, product:, quantity: 1)

          cart_item.save!

          expect(cart_item.total_price).to eq(20)
        end
      end

      context 'when updating a cart item' do
        it 'updates the total price' do
          cart_item = create(:cart_item, product:, quantity: 1)

          cart_item.update!(quantity: 3)

          expect(cart_item.total_price).to eq(60)
        end
      end
    end
  end
end
