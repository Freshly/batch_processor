# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Controller, type: :module do
  include_context "with an example batch"

  it { is_expected.to delegate_method(:pipelined).to(:details) }
  it { is_expected.to delegate_method(:allow_empty?).to(:class) }
  it { is_expected.to delegate_method(:name).to(:class).with_prefix(true) }

  describe ".allow_empty" do
    subject(:allow_empty) { example_batch_class.__send__(:allow_empty) }

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

    let(:collection_valid?) { true }

    before { allow(example_batch.collection).to receive(:valid?).and_return(collection_valid?) }

    context "with the collection is invalid" do
      let(:collection_valid?) { false }

      it "raises" do
        expect { start }.to raise_error BatchProcessor::CollectionInvalidError
      end
    end

    context "when already started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      it "raises" do
        expect { start }.to raise_error BatchProcessor::AlreadyStartedError
      end
    end

    context "when not started" do
      before { allow(example_batch).to receive(:collection_items).and_return(collection_items) }

      shared_examples_for "the batch starts" do
        it { is_expected.to eq true }

        it "starts processing the batch" do
          expect { start }.
            to change { example_batch.details.class_name }.from(nil).to(example_batch_name).
            and change { example_batch.started? }.from(false).to(true).
            and change { example_batch.details.started_at }.from(nil).to(Time.current).
            and change { example_batch.details.size }.from(0).to(collection_items.size).
            and change { example_batch.details.pending_jobs_count }.from(0).to(collection_items.size)
        end

        it_behaves_like "a class with callback" do
          include_context "with callbacks", :batch_started

          subject(:callback_runner) { start }

          let(:example) { example_batch }
          let(:example_class) { example.class }
        end

        it_behaves_like "a surveiled event", :batch_started do
          let(:expected_class) { example_batch_class.name }

          before { start }
        end
      end

      context "with an empty collection" do
        let(:collection_items) { [] }

        context "when not allow_blank?" do
          it "raises" do
            expect { start }.to raise_error BatchProcessor::CollectionEmptyError
          end
        end
      end

      context "with a present collection" do
        let(:collection_items) { Faker::Lorem.words }

        it_behaves_like "the batch starts"
      end
    end
  end

  describe "#enqueued", type: :with_frozen_time do
    subject(:enqueued) { example_batch.enqueued }

    context "when already enqueued" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "enqueued_at", Time.now) }

      it "raises" do
        expect { enqueued }.to raise_error BatchProcessor::AlreadyEnqueuedError
      end
    end

    context "when not started" do
      it "raises" do
        expect { enqueued }.to raise_error BatchProcessor::NotStartedError
      end
    end

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      it { is_expected.to eq true }

      it "marks the batch as enqueued" do
        expect { enqueued }.
        to change { example_batch.enqueued? }.from(false).to(true).
        and change { example_batch.details.enqueued_at }.from(nil).to(Time.current)
      end

      it_behaves_like "a class with callback" do
        include_context "with callbacks", :batch_enqueued

        subject(:callback_runner) { enqueued }

        let(:example) { example_batch }
        let(:example_class) { example.class }
      end

      it_behaves_like "a surveiled event", :batch_enqueued do
        let(:expected_class) { example_batch_class.name }

        before { enqueued }
      end
    end
  end

  describe "#abort!", type: :with_frozen_time do
    subject(:abort!) { example_batch.abort! }

    context "when not started" do
      it "raises" do
        expect { abort! }.to raise_error BatchProcessor::NotStartedError
      end
    end

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      context "when already aborted" do
        before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "aborted_at", Time.now) }

        it "raises" do
          expect { abort! }.to raise_error BatchProcessor::AlreadyAbortedError
        end
      end

      context "when finished" do
        before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "finished_at", Time.now) }

        it "raises" do
          expect { abort! }.to raise_error BatchProcessor::AlreadyFinishedError
        end
      end

      context "with unfinished and not aborted" do
        it { is_expected.to eq true }

        it "marks the batch as aborted" do
          expect { abort! }.
            to change { example_batch.aborted? }.from(false).to(true).
            and change { example_batch.details.aborted_at }.from(nil).to(Time.current)
        end

        it_behaves_like "a class with callback" do
          include_context "with callbacks", :batch_aborted

          subject(:callback_runner) { abort! }

          let(:example) { example_batch }
          let(:example_class) { example.class }
        end

        it_behaves_like "a surveiled event", :batch_aborted do
          let(:expected_class) { example_batch_class.name }

          before { abort! }
        end
      end
    end
  end

  describe "#clear!", type: :with_frozen_time do
    subject(:clear!) { example_batch.clear! }

    context "when not aborted" do
      it "raises" do
        expect { clear! }.to raise_error BatchProcessor::NotAbortedError
      end
    end

    context "when aborted" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "aborted_at", Time.now) }

      context "when already finished" do
        before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "finished_at", Time.now) }

        it "raises" do
          expect { clear! }.to raise_error BatchProcessor::AlreadyFinishedError
        end
      end

      context "when already cleared" do
        before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "cleared_at", Time.now) }

        it "raises" do
          expect { clear! }.to raise_error BatchProcessor::AlreadyClearedError
        end
      end

      context "when not cleared" do
        let(:pending_jobs_count) { rand(5..10) }
        let(:running_jobs_count) { rand(5..10) }
        let(:expected_cleared_jobs_count) { pending_jobs_count + running_jobs_count }

        before do
          key = BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id)
          Redis.new.hset(key, "pending_jobs_count", pending_jobs_count)
          Redis.new.hset(key, "running_jobs_count", running_jobs_count)
        end

        it { is_expected.to eq true }

        it "clears the batch and marks it as such" do
          expect { clear! }.
            to change { example_batch.details.cleared_at }.from(nil).to(Time.current).
            and change { example_batch.details.finished_at }.from(nil).to(Time.current).
            and change { example_batch.details.pending_jobs_count }.from(pending_jobs_count).to(0).
            and change { example_batch.details.running_jobs_count }.from(running_jobs_count).to(0).
            and change { example_batch.details.cleared_jobs_count }.from(0).to(expected_cleared_jobs_count)
        end

        it_behaves_like "a class with callback" do
          include_context "with callbacks", :batch_cleared

          subject(:callback_runner) { clear! }

          let(:example) { example_batch }
          let(:example_class) { example.class }
        end

        it_behaves_like "a surveiled event", :batch_cleared do
          let(:expected_class) { example_batch_class.name }

          before { clear! }
        end
      end
    end
  end

  describe "#finish", type: :with_frozen_time do
    subject(:finish) { example_batch.finish }

    context "when already finished" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "finished_at", Time.now) }

      it "raises" do
        expect { finish }.to raise_error BatchProcessor::AlreadyFinishedError
      end
    end

    context "when not finished" do
      context "with pending jobs" do
        before do
          Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "pending_jobs_count", 1)
        end

        it "raises" do
          expect { finish }.to raise_error BatchProcessor::StillProcessingError
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

        it_behaves_like "a surveiled event", :batch_finished do
          let(:expected_class) { example_batch_class.name }

          before { finish }
        end
      end
    end
  end
end
