# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Process, type: :module do
  include_context "with an example processor", described_class

  describe "#process" do
    subject(:process) { example_processor.process }

    context "when already started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      it "raises" do
        expect { process }.to raise_error BatchProcessor::BatchAlreadyStartedError
      end
    end

    context "when not started" do
      it_behaves_like "processing starts"
    end
  end
end
