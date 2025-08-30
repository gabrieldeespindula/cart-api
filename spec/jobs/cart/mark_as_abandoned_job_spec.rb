require 'rails_helper'

RSpec.describe Cart::MarkAsAbandonedJob, type: :job do
  subject { described_class }

  describe '#perform' do
    it 'enqueues the job' do
      expect { subject.perform_later }
        .to have_enqueued_job(Cart::MarkAsAbandonedJob)
    end

    it 'executes the job' do
      expect(Cart::MarkAsAbandoned).to receive(:call).once.with(no_args).and_call_original

      perform_enqueued_jobs { subject.perform_later }
    end
  end
end
