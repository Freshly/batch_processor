# frozen_string_literal: true

RSpec.shared_examples_for "the batch must be processing" do
  context "when already finished" do
    before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "finished_at", Time.now) }

    it "raises" do
      expect { subject }.to raise_error BatchProcessor::BatchNotProcessingError
    end
  end

  context "when not started" do
    it "raises" do
      expect { subject }.to raise_error BatchProcessor::BatchNotProcessingError
    end
  end
end
