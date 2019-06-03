# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::JobController, type: :module do
  include_context "with an example batch", [
    BatchProcessor::Batch::Collection,
    BatchProcessor::Batch::Predicates,
    described_class,
  ]

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
          and change { example_batch.details.running_jobs_count }.by(-1)
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
end
