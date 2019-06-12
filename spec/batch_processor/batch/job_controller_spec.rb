# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::JobController, type: :module do
  include_context "with an example batch"

  describe "#job_enqueued" do
    subject(:job_enqueued) { example_batch.job_enqueued }

    it_behaves_like "the batch must be processing"

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      let(:collection) { Faker::Lorem.words }

      it { is_expected.to eq 1 }

      it "track job" do
        expect { job_enqueued }.to change { example_batch.details.enqueued_jobs_count }.by(1)
      end

      it_behaves_like "a class with callback" do
        include_context "with callbacks", :job_enqueued

        subject(:callback_runner) { job_enqueued }

        let(:example) { example_batch }
        let(:example_class) { example.class }
      end

      it_behaves_like "a surveiled event", :job_enqueued do
        let(:expected_class) { example_batch_class.name }

        before { job_enqueued }
      end
    end
  end

  describe "#job_running" do
    subject(:job_running) { example_batch.job_running }

    it_behaves_like "the batch must be processing"

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      let(:collection) { Faker::Lorem.words }

      it { is_expected.to eq [ 1, -1 ] }

      it "tracks job" do
        expect { job_running }.
          to change  { example_batch.details.running_jobs_count }.by(1).
          and change { example_batch.details.pending_jobs_count }.by(-1)
      end

      it_behaves_like "a class with callback" do
        include_context "with callbacks", :job_running

        subject(:callback_runner) { job_running }

        let(:example) { example_batch }
        let(:example_class) { example.class }
      end

      it_behaves_like "a surveiled event", :job_running do
        let(:expected_class) { example_batch_class.name }

        before { job_running }
      end
    end
  end

  describe "#job_success" do
    subject(:job_success) { example_batch.job_success }

    context "when not started" do
      it "raises" do
        expect { subject }.to raise_error BatchProcessor::BatchNotStartedError
      end
    end

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      let(:collection) { Faker::Lorem.words }

      context "when already finished" do
        before do
          Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "finished_at", Time.now)
        end

        it "raises" do
          expect { subject }.to raise_error BatchProcessor::BatchAlreadyFinishedError
        end
      end

      context "when not finished" do
        it { is_expected.to eq [ 1, -1 ] }

        it "tracks job" do
          expect { job_success }.
            to change  { example_batch.details.successful_jobs_count }.by(1).
            and change { example_batch.details.running_jobs_count }.by(-1)
        end

        it_behaves_like "a class with callback" do
          include_context "with callbacks", :job_success

          subject(:callback_runner) { job_success }

          let(:example) { example_batch }
          let(:example_class) { example.class }
        end

        it_behaves_like "a surveiled event", :job_success do
          let(:expected_class) { example_batch_class.name }

          before { job_success }
        end
      end
    end
  end

  describe "#job_failure" do
    subject(:job_failure) { example_batch.job_failure }

    context "when not started" do
      it "raises" do
        expect { subject }.to raise_error BatchProcessor::BatchNotStartedError
      end
    end

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      let(:collection) { Faker::Lorem.words }

      context "when already finished" do
        before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "finished_at", Time.now) }

        it "raises" do
          expect { subject }.to raise_error BatchProcessor::BatchAlreadyFinishedError
        end
      end

      context "when not finished" do
        it { is_expected.to eq [ 1, -1 ] }

        it "tracks job" do
          expect { job_failure }.
          to change  { example_batch.details.failed_jobs_count }.by(1).
          and change { example_batch.details.running_jobs_count }.by(-1)
        end

        it_behaves_like "a class with callback" do
          include_context "with callbacks", :job_failure

          subject(:callback_runner) { job_failure }

          let(:example) { example_batch }
          let(:example_class) { example.class }
        end

        it_behaves_like "a surveiled event", :job_failure do
          let(:expected_class) { example_batch_class.name }

          before { job_failure }
        end
      end
    end
  end

  describe "#job_retried" do
    subject(:job_retried) { example_batch.job_retried }

    it_behaves_like "the batch must be processing"

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now) }

      let(:collection) { Faker::Lorem.words }

      it { is_expected.to eq [ 1, 1, -1 ] }

      it "tracks job" do
        expect { job_retried }.
          to change  { example_batch.details.total_retries_count }.by(1).
          and change { example_batch.details.pending_jobs_count }.by(1).
          and change { example_batch.details.failed_jobs_count }.by(-1)
      end

      it_behaves_like "a class with callback" do
        include_context "with callbacks", :job_retried

        subject(:callback_runner) { job_retried }

        let(:example) { example_batch }
        let(:example_class) { example.class }
      end

      it_behaves_like "a surveiled event", :job_retried do
        let(:expected_class) { example_batch_class.name }

        before { job_retried }
      end
    end
  end

  describe "#job_canceled" do
    subject(:job_canceled) { example_batch.job_canceled }

    context "when not aborted" do
      it "raises" do
        expect { subject }.to raise_error BatchProcessor::BatchNotAbortedError
      end
    end

    context "when aborted" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "aborted_at", Time.now) }

      let(:collection) { Faker::Lorem.words }

      it { is_expected.to eq [ 1, -1 ] }

      it "tracks job" do
        expect { job_canceled }.
          to change  { example_batch.details.canceled_jobs_count }.by(1).
          and change { example_batch.details.pending_jobs_count }.by(-1)
      end

      it_behaves_like "a class with callback" do
        include_context "with callbacks", :job_canceled

        subject(:callback_runner) { job_canceled }

        let(:example) { example_batch }
        let(:example_class) { example.class }
      end

      it_behaves_like "a surveiled event", :job_canceled do
        let(:expected_class) { example_batch_class.name }

        before { job_canceled }
      end
    end
  end

  shared_examples_for "batch is finished when last" do |increment_field, decrement_field = :running_jobs_count|
    before do
      Redis.new.tap do |redis|
        redis.pipelined do
          redis_key = BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id)
          redis.hset(redis_key, "started_at", Time.now)
          redis.hset(redis_key, decrement_field, decrement_count)
        end
      end
    end

    context "when the last job" do
      let(:decrement_count) { 1 }

      it { is_expected.to eq [ 1, 0 ] }

      it "completes the batch" do
        expect { subject }.
          to change  { example_batch.details.public_send(increment_field) }.by(1).
          and change { example_batch.details.public_send(decrement_field) }.by(-1).
          and change { example_batch.details.finished_at }.from(nil).to(Time.current).
          and change { example_batch.finished? }.from(false).to(true)
      end
    end

    context "when not the last job" do
      let(:decrement_count) { 2 }

      it { is_expected.to eq [ 1, 1 ] }

      it "does not complete the batch" do
        expect { subject }.
          to change  { example_batch.details.public_send(increment_field) }.by(1).
          and change { example_batch.details.public_send(decrement_field) }.by(-1)

        expect(example_batch.details.finished_at).to be_nil
        expect(example_batch).not_to be_finished
      end
    end
  end

  describe ".on_job_success callback", type: :with_frozen_time do
    subject(:job_success) { example_batch.job_success }

    it_behaves_like "batch is finished when last", :successful_jobs_count
  end

  describe ".on_job_failure callback", type: :with_frozen_time do
    subject(:job_failure) { example_batch.job_failure }

    it_behaves_like "batch is finished when last", :failed_jobs_count
  end

  describe ".on_job_canceled callback", type: :with_frozen_time do
    subject(:job_failure) { example_batch.job_canceled }

    before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "aborted_at", Time.now) }

    it_behaves_like "batch is finished when last", :canceled_jobs_count, :pending_jobs_count
  end
end
