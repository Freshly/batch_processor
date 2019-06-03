# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::JobController, type: :module do
  include_context "with an example batch", [
    BatchProcessor::Batch::Collection,
    BatchProcessor::Batch::Predicates,
    described_class,
  ]

  shared_examples_for "the batch must be processing" do
    context "when already finished" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "finished_at", Time.now) }

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

  describe "#job_enqueued" do
    subject(:job_enqueued) { example_batch.job_enqueued }

    it_behaves_like "the batch must be processing"

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

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
    end
  end

  describe "#job_running" do
    subject(:job_running) { example_batch.job_running }

    it_behaves_like "the batch must be processing"

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

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
    end
  end

  describe "#job_retried" do
    subject(:job_retried) { example_batch.job_retried }

    it_behaves_like "the batch must be processing"

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

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
    end
  end

  describe "#job_canceled" do
    subject(:job_canceled) { example_batch.job_canceled }

    it_behaves_like "the batch must be processing"

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

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
    end
  end
end
