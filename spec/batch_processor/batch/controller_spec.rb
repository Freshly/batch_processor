# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Controller, type: :module do
  include_context "with an example batch", [ BatchProcessor::Batch::Predicates, described_class ]

  describe "#start" do
    subject(:start) { example_batch.start }

    context "when already started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

      it "raises" do
        expect { start }.to raise_error BatchProcessor::BatchAlreadyStartedError
      end
    end

    context "when not started" do
      it "doesn't raise" do
        expect { start }.not_to raise_error
      end
    end
  end
end
