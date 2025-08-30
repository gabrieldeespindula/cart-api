require 'rails_helper'

RSpec.describe Cart::MarkAsAbandoned, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  describe '#call' do
    before { freeze_time }

    context 'when there are abandonable carts' do
      let!(:abandonable_cart) { create(:cart, abandoned: false, last_interaction_at: 3.hours.ago - 1.second) }
      let!(:active_cart) { create(:cart, abandoned: false, last_interaction_at: 3.hours.ago) }
      let!(:already_abandoned_cart) { create(:cart, abandoned: true, last_interaction_at: 4.hours.ago) }


      it 'marks an abandonable cart as abandoned' do
        expect { subject.call }.to change { abandonable_cart.reload.abandoned }.from(false).to(true)
      end

      it 'does not change an active cart' do
        expect { subject.call }.not_to change { active_cart.reload.attributes }
      end

      it 'does not change an already abandoned cart' do
        expect { subject.call }.not_to change { already_abandoned_cart.reload.attributes }
      end

      it 'logs the process correctly' do
        expect(Rails.logger).to receive(:info).with("Starting to mark carts as abandoned...").ordered
        expect(Rails.logger).to receive(:info).with(/Processing batch #1 \(1 carts\)/).ordered
        expect(Rails.logger).to receive(:info).with("Finished marking carts as abandoned.").ordered

        subject.call
      end
    end

    context 'when there are no abandonable carts' do
      it 'does not log any batch processing' do
        expect(Rails.logger).not_to receive(:info).with(/Processing batch/)
        subject.call
      end

      it 'runs without errors' do
        expect { subject.call }.not_to raise_error
      end
    end
  end
end
