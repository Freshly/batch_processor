# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchJob, type: :job do
  include_context "with an example batch"

  subject(:batch_job) { example_class.new(*arguments) }

  let(:example_class) do
    Class.new(described_class) do
      def perform(*)
        :performed
      end
    end
  end

  let(:batch_id) { SecureRandom.hex }
  let(:arguments) { Faker::Lorem.words }
  let(:example_class_name) { "Example#{Faker::Internet.domain_word.capitalize}" }

  before { stub_const(example_class_name, example_class) }

  it { is_expected.to inherit_from ActiveJob::Base }

  describe described_class::BatchAbortedError do
    subject { described_class }

    it { is_expected.to inherit_from StandardError }
  end

  describe "#serialize" do
    subject { batch_job.serialize }

    before { batch_job.batch_id = batch_id }

    let(:expected_fragment) { Hash["arguments", arguments, "batch_id", batch_id] }

    context "without a batch" do
      let(:batch_id) { nil }

      it { is_expected.to include expected_fragment }
    end

    context "with a batch" do
      it { is_expected.to include expected_fragment }
    end
  end

  describe "#deserialize" do
    subject(:deserialize) { batch_job.deserialize(serialized_hash_fragment) }

    let(:job_id) { SecureRandom.hex }
    let(:batch_job) { example_class.new }
    let(:serialized_hash_fragment) { Hash["job_id", job_id, "batch_id", batch_id] }

    context "without a batch" do
      let(:batch_id) { nil }

      it "deserializes arguments" do
        expect { deserialize }.to change { batch_job.job_id }.to(job_id)
      end
    end

    context "with a batch" do
      it "deserializes attributes" do
        expect { deserialize }.to change { batch_job.batch_id }.to(batch_id).and change { batch_job.job_id }.to(job_id)
      end
    end
  end

  shared_context "with the example batch stored in redis" do
    before do
      Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "class_name", example_batch_name)
    end
  end

  describe "#batch" do
    subject { batch_job.batch }

    context "without a batch" do
      let(:batch_id) { nil }

      it { is_expected.to be_nil }
    end

    context "with a batch" do
      include_context "with the example batch stored in redis"

      before { batch_job.batch_id = batch_id }

      it { is_expected.to be_an_instance_of example_batch_class }
      it { is_expected.to have_attributes(batch_id: batch_id) }
    end
  end

  describe "#batch_job?" do
    subject { batch_job.batch_job? }

    before { batch_job.batch_id = batch_id }

    context "without a batch" do
      let(:batch_id) { nil }

      it { is_expected.to eq false }
    end

    context "with a batch" do
      include_context "with the example batch stored in redis"

      it { is_expected.to eq true }
    end
  end

  describe ".after_enqueue" do
    subject(:enqueue) { batch_job.enqueue }

    shared_examples_for "job is enqueued" do
      let(:expected_job) { batch_job.serialize }

      it "is enqueued" do
        expect { enqueue }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs }.from([]).to([ expected_job ])
      end
    end

    shared_examples_for "normal without a batch" do
      context "without a batch" do
        let(:batch_id) { nil }

        it_behaves_like "job is enqueued"
      end
    end

    context "when first execution" do
      it_behaves_like "normal without a batch"

      context "with a batch" do
        include_context "with the example batch stored in redis"

        before { batch_job.batch_id = batch_id }

        it_behaves_like "the batch must be processing"

        context "when started" do
          before do
            Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now)
          end

          it_behaves_like "job is enqueued"

          it "updates the batch" do
            expect { enqueue }.to change { example_batch.details.enqueued_jobs_count }.by(1)
          end
        end
      end
    end

    context "when other execution" do
      before { batch_job.executions = 1 }

      it_behaves_like "normal without a batch"

      context "with a batch" do
        include_context "with the example batch stored in redis"

        before { batch_job.batch_id = batch_id }

        it_behaves_like "the batch must be processing"

        context "when started" do
          before do
            Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now)
          end

          it_behaves_like "job is enqueued"

          it "updates the batch" do
            expect { enqueue }.
              to change { example_batch.details.total_retries_count }.by(1).
              and change { example_batch.details.pending_jobs_count }.by(1).
              and change { example_batch.details.failed_jobs_count }.by(-1)
          end
        end
      end
    end
  end

  describe ".(before|after)_perform" do
    subject(:perform_now) { batch_job.perform_now }

    shared_examples_for "job is performed" do
      it { is_expected.to eq :performed }
    end

    context "without a batch" do
      let(:batch_id) { nil }

      it_behaves_like "job is performed"
    end

    context "with a batch" do
      include_context "with the example batch stored in redis"

      before { batch_job.batch_id = batch_id }

      context "when aborted" do
        before do
          Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now)
          Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "aborted_at", Time.now)
        end

        it { is_expected.to be_an_instance_of described_class::BatchAbortedError }

        it "updates the batch" do
          expect { perform_now }.
            to change { example_batch.details.canceled_jobs_count }.by(1).
            and change { example_batch.details.pending_jobs_count }.by(-1)
        end
      end

      context "when NOT aborted" do
        context "when started" do
          before do
            Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now)
            allow(batch_job.batch).to receive(:job_running).and_call_original
          end

          it_behaves_like "job is performed"

          it "updates the batch" do
            expect { perform_now }.
              to change { example_batch.details.pending_jobs_count }.by(-1).
              and change { example_batch.details.successful_jobs_count }.by(1)

            # The job finishes in this execution, so we need to check the runner was called
            expect(batch_job.batch).to have_received(:job_running)
          end
        end
      end
    end
  end

  describe ".discard_on StandardError" do
    subject(:perform_now) { batch_job.perform_now }

    let(:reason) { Faker::Lorem.sentence }

    before { allow(batch_job).to receive(:perform).and_raise StandardError, reason }

    context "without a batch" do
      let(:batch_id) { nil }

      it "raises" do
        expect { perform_now }.to raise_error StandardError, reason
      end
    end

    context "with a batch" do
      include_context "with the example batch stored in redis"

      before { batch_job.batch_id = batch_id }

      context "when started" do
        before do
          Redis.new.hset(BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id), "started_at", Time.now)
          allow(batch_job.batch).to receive(:job_running).and_call_original
        end

        it { is_expected.to be_an_instance_of(StandardError) }
        it { is_expected.to have_attributes(message: reason) }

        it "updates the batch" do
          expect { perform_now }.
            to change { example_batch.details.pending_jobs_count }.by(-1).
            and change { example_batch.details.failed_jobs_count }.by(1)

          # The job fails in this execution, so we need to check the runner was called
          expect(batch_job.batch).to have_received(:job_running)
        end
      end
    end
  end
end
