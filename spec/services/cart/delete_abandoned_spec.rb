require 'rails_helper'

RSpec.describe Cart::DeleteAbandoned, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  describe '#call' do
    before { freeze_time }

    let!(:deletable_cart) do
      create(:cart, abandoned: true, last_interaction_at: 7.days.ago - 1.second)
    end

    let!(:recent_abandoned_cart) do
      create(:cart, abandoned: true, last_interaction_at: 7.days.ago + 1.second)
    end

    let!(:active_cart) { create(:cart, abandoned: false, last_interaction_at: 8.days.ago) }

    it 'deletes carts abandoned for more than 7 days' do
      expect { subject.call }.to change(Cart, :count).by(-1)

      expect(Cart.exists?(deletable_cart.id)).to be_falsey
    end

    it 'does not delete carts abandoned for less than 7 days' do
      expect { subject.call }.not_to change { Cart.exists?(recent_abandoned_cart.id) }
    end

    it 'does not delete active carts' do
      expect { subject.call }.not_to change { Cart.exists?(active_cart.id) }
    end

    it 'logs the process correctly' do
      expect(Rails.logger).to receive(:info).with("Starting to delete abandoned carts...").ordered
      expect(Rails.logger).to receive(:info).with(/Processing batch #1: Deleting 1 carts/).ordered
      expect(Rails.logger).to receive(:info).with("Finished deleting abandoned carts.").ordered

      subject.call
    end
  end
end
