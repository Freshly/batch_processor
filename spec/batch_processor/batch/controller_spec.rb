# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Controller, type: :module do
  include_context "with an example batch", [
    BatchProcessor::Batch::Collection,
    BatchProcessor::Batch::Predicates,
    described_class,
  ]

  it { is_expected.to delegate_method(:pipelined).to(:details) }
  it { is_expected.to delegate_method(:allow_empty?).to(:class) }

  describe ".allow_empty" do
    subject(:allow_empty) { example_batch_class.allow_empty }

    it "sets @allow_empty" do
      expect { allow_empty }.to change { example_batch_class.instance_variable_get(:@allow_empty) }.from(nil).to(true)
    end
  end

  describe ".allow_empty?" do
    subject { example_batch_class.allow_empty? }

    context "when @allow_empty is set" do
      before { example_batch_class.instance_variable_set(:@allow_empty, true) }

      it { is_expected.to eq true }
    end

    context "when @allow_empty is not set" do
      it { is_expected.to eq false }
    end
  end

  describe "#start", type: :with_frozen_time do
    subject(:start) { example_batch.start }

    context "when already started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

      it "raises" do
        expect { start }.to raise_error BatchProcessor::BatchAlreadyStartedError
      end
    end

    context "when not started" do
      before { allow(example_batch).to receive(:collection).and_return(collection) }

      shared_examples_for "the batch starts" do
        it { is_expected.to eq true }

        it "starts processing the batch" do
          expect { start }.
            to change { example_batch.started? }.from(false).to(true).
            and change { example_batch.details.started_at }.from(nil).to(Time.current).
            and change { example_batch.details.size }.from(0).to(collection.size).
            and change { example_batch.details.pending_jobs_count }.from(0).to(collection.size)
        end

        it_behaves_like "a class with callback" do
          include_context "with callbacks", :batch_started

          subject(:callback_runner) { start }

          let(:example) { example_batch }
          let(:example_class) { example.class }
        end
      end

      context "with an empty collection" do
        let(:collection) { [] }

        context "when not allow_blank?" do
          it "raises" do
            expect { start }.to raise_error BatchProcessor::BatchEmptyError
          end
        end
      end

      context "with a present collection" do
        let(:collection) { Faker::Lorem.words }

        it_behaves_like "the batch starts"
      end
    end
  end

  describe "#finish", type: :with_frozen_time do
    subject(:finish) { example_batch.finish }

    context "when already finished" do
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
          expect { finish }.
            to change { example_batch.finished? }.from(false).to(true).
            and change { example_batch.details.finished_at }.from(nil).to(Time.current)
        end

        it_behaves_like "a class with callback" do
          include_context "with callbacks", :batch_finished

          subject(:callback_runner) { finish }

          let(:example) { example_batch }
          let(:example_class) { example.class }
        end
      end
    end
  end
end
