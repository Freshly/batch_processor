# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Controller, type: :module do
  include_context "with an example batch", [
    BatchProcessor::Batch::Collection,
    BatchProcessor::Batch::Predicates,
    described_class,
  ]

  it { is_expected.to delegate_method(:pipelined).to(:details) }

  describe "#start" do
    subject(:start) { example_batch.start }

    context "when already started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

      it "raises" do
        expect { start }.to raise_error BatchProcessor::BatchAlreadyStartedError
      end
    end

    context "when not started" do
      it_behaves_like "processing starts"

      it { is_expected.to eq true }
    end
  end

  describe "#finish" do
    subject(:finish) { example_batch.finish }

    context "when already finish" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "finished_at", Time.now) }

      it "raises" do
        expect { finish }.to raise_error BatchProcessor::BatchAlreadyFinishedError
      end
    end

    context "when not finished" do
      context "with pending jobs" do
        before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "pending_jobs_count", 1) }

        it "raises" do
          expect { finish }.to raise_error BatchProcessor::BatchStillProcessingError
        end
      end

      context "without pending jobs" do
        it { is_expected.to eq true }

        it "finishes the batch" do
          expect { subject }.
            to change { example_batch.finished? }.from(false).to(true).
            and change { example_batch.details.finished_at&.change(usec: 0) }.from(nil).to(Time.current.change(usec: 0))
        end
      end
    end
  end
end
