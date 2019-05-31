# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::JobController, type: :module do
  include_context "with an example batch", [
    BatchProcessor::Batch::Collection,
    BatchProcessor::Batch::Predicates,
    described_class,
  ]

  describe "#job_enqueued" do
    subject(:job_enqueued) { example_batch.job_enqueued }

    context "when already finished" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "finished_at", Time.now) }

      it "raises" do
        expect { job_enqueued }.to raise_error BatchProcessor::BatchNotProcessingError
      end
    end

    context "when not started" do
      it "raises" do
        expect { job_enqueued }.to raise_error BatchProcessor::BatchNotProcessingError
      end
    end

    context "when started" do
      before { Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(id), "started_at", Time.now) }

      let(:collection) { Faker::Lorem.words }

      it { is_expected.to eq true }

      it "starts processing the batch" do
        expect { job_enqueued }.to change { example_batch.details.enqueued_jobs_count }.from(0).to(1)
      end

      it_behaves_like "a class with callback" do
        include_context "with callbacks", :job_enqueued

        subject(:callback_runner) { job_enqueued }

        let(:example) { example_batch }
        let(:example_class) { example.class }
      end
    end
  end
end
