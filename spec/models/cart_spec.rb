require 'rails_helper'

RSpec.describe Cart, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:total_price).is_greater_than_or_equal_to(0).allow_nil }
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

  describe 'scopes' do
    describe '.abandonable' do
      before { freeze_time }

      let!(:cart_just_before_limit) { create(:cart, last_interaction_at: 3.hours.ago + 1.second) }
      let!(:cart_exactly_on_limit) { create(:cart, last_interaction_at: 3.hours.ago) }
      let!(:cart_just_after_limit) { create(:cart, last_interaction_at: 3.hours.ago - 1.second) }

      it 'includes carts with last interaction more than 3 hours ago' do
        expect(described_class.abandonable).to include(cart_just_after_limit)
      end

      it 'excludes carts with last interaction exactly 3 hours ago' do
        expect(described_class.abandonable).not_to include(cart_exactly_on_limit)
      end

      it 'excludes carts with last interaction less than 3 hours ago' do
        expect(described_class.abandonable).not_to include(cart_just_before_limit)
      end

      it 'ignores carts already abandoned' do
        cart_just_after_limit.update(abandoned: true)
        expect(described_class.abandonable).not_to include(cart_just_after_limit)
      end

      it 'returns only the correct carts' do
        expect(described_class.abandonable).to contain_exactly(cart_just_after_limit)
      end
    end

    describe '.deletable' do
      before { freeze_time }

      let!(:cart_just_before_limit) { create(:cart, abandoned: true, last_interaction_at: 7.days.ago + 1.second) }
      let!(:cart_exactly_on_limit) { create(:cart, abandoned: true, last_interaction_at: 7.days.ago) }
      let!(:cart_just_after_limit) { create(:cart, abandoned: true, last_interaction_at: 7.days.ago - 1.second) }

      it 'includes carts with last interaction more than 7 days ago' do
        expect(described_class.deletable).to include(cart_just_after_limit)
      end

      it 'excludes carts with last interaction exactly 7 days ago' do
        expect(described_class.deletable).not_to include(cart_exactly_on_limit)
      end

      it 'excludes carts with last interaction less than 7 days ago' do
        expect(described_class.deletable).not_to include(cart_just_before_limit)
      end

      it 'ignores carts not abandoned' do
        cart_just_after_limit.update(abandoned: false)
        expect(described_class.deletable).not_to include(cart_just_after_limit)
      end

      it 'returns only the correct carts' do
        expect(described_class.deletable).to contain_exactly(cart_just_after_limit)
      end
    end
  end
end
