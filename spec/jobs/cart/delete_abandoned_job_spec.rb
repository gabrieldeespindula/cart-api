require 'rails_helper'

RSpec.describe Cart::DeleteAbandonedJob, type: :job do
  subject { described_class }

  describe '#perform' do
    it 'enqueues the job' do
      expect { subject.perform_later }
        .to have_enqueued_job(Cart::DeleteAbandonedJob)
    end

    it 'executes the job' do
      expect(Cart::DeleteAbandoned).to receive(:call).once.with(no_args).and_call_original

      perform_enqueued_jobs { subject.perform_later }
    end
  end
end
