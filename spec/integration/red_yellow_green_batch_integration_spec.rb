# frozen_string_literal: true

RSpec.describe RedYellowGreenBatch, type: :integration do
  subject(:process) { batch.process }

  let(:enqueued_jobs) { ActiveJob::Base.queue_adapter.enqueued_jobs }
  let(:batch) { described_class.new }
  let(:details) { batch.details }
  let(:expected_size) { batch.collection_items.count }
  let(:alerter) { Alerter.new }

  before { process }

  it "triggers the right batch callbacks" do
    expect(alerter.count_batch_started).to eq 1
    expect(alerter.count_batch_enqueued).to eq 1
    expect(alerter.count_batch_aborted).to eq 0
    expect(alerter.count_batch_cleared).to eq 0
    expect(alerter.count_batch_finished).to eq 0
  end

  it "triggers the right job callbacks" do
    expect(alerter.count_job_enqueued).to eq 3
    expect(alerter.count_job_running).to eq 0
    expect(alerter.count_job_retried).to eq 0
    expect(alerter.count_job_canceled).to eq 0
    expect(alerter.count_job_success).to eq 0
    expect(alerter.count_job_failure).to eq 0
  end

  shared_examples_for "the light is processed" do |index, result, success_count: 0, failure_count: 0|
    it "processes the light" do
      expect { ActiveJob::Base.execute enqueued_jobs[index] }.
        to change { details.pending_jobs_count }.by(-1).
        and change { details.public_send(result) }.by(1).
        and change { details.finished_jobs_count }.by(1)
    end

    context "with callbacks" do
      before { ActiveJob::Base.execute enqueued_jobs[index] }

      it "triggers the right batch callbacks" do
        expect(alerter.count_batch_started).to eq 1
        expect(alerter.count_batch_enqueued).to eq 1
        expect(alerter.count_batch_aborted).to eq 0
        expect(alerter.count_batch_cleared).to eq 0
        expect(alerter.count_batch_finished).to eq 0
      end

      it "triggers the right job callbacks" do
        expect(alerter.count_job_enqueued).to eq 3
        expect(alerter.count_job_running).to eq 1
        expect(alerter.count_job_retried).to eq 0
        expect(alerter.count_job_canceled).to eq 0
        expect(alerter.count_job_success).to eq success_count
        expect(alerter.count_job_failure).to eq failure_count
      end
    end
  end

  context "with the red light" do
    it_behaves_like "the light is processed", 0, :failed_jobs_count, failure_count: 1
  end

  context "with the yellow light" do
    it "processes the retry" do
      expect { ActiveJob::Base.execute enqueued_jobs[1] }.to change { details.total_retries_count }.by(1)
      expect { ActiveJob::Base.execute enqueued_jobs.last }.
        to change { details.pending_jobs_count }.by(-1).
        and change { details.successful_jobs_count }.by(1).
        and change { details.finished_jobs_count }.by(1)
    end

    context "with callbacks" do
      before { ActiveJob::Base.execute enqueued_jobs[1] }

      it "triggers the right batch callbacks" do
        expect(alerter.count_batch_started).to eq 1
        expect(alerter.count_batch_enqueued).to eq 1
        expect(alerter.count_batch_aborted).to eq 0
        expect(alerter.count_batch_cleared).to eq 0
        expect(alerter.count_batch_finished).to eq 0
      end

      it "triggers the right job callbacks" do
        expect(alerter.count_job_enqueued).to eq 3
        expect(alerter.count_job_running).to eq 1
        expect(alerter.count_job_retried).to eq 1
        expect(alerter.count_job_canceled).to eq 0
        expect(alerter.count_job_success).to eq 0
        expect(alerter.count_job_failure).to eq 1
      end
    end
  end

  context "with the green light" do
    it_behaves_like "the light is processed", 2, :successful_jobs_count, success_count: 1
  end

  context "when the batch is aborted" do
    subject { details }

    before do
      processor = ActiveJob::Base.method(:execute)
      enqueued_jobs.shift(2).each(&processor)
      batch.abort!
      enqueued_jobs.each(&processor)
    end

    let(:expected_attributes) do
      { size: expected_size,
        enqueued_jobs_count: expected_size,
        pending_jobs_count: 0,
        running_jobs_count: 0,
        total_retries_count: 1,
        successful_jobs_count: 0,
        failed_jobs_count: 1,
        canceled_jobs_count: 2,
        cleared_jobs_count: 0,
        aborted_at: Time.current,
        finished_at: Time.current }
    end

    it { is_expected.to have_attributes expected_attributes }

    it "triggers the right batch callbacks" do
      expect(alerter.count_batch_started).to eq 1
      expect(alerter.count_batch_enqueued).to eq 1
      expect(alerter.count_batch_aborted).to eq 1
      expect(alerter.count_batch_finished).to eq 1
    end

    it "triggers the right job callbacks" do
      expect(alerter.count_job_enqueued).to eq 3
      expect(alerter.count_job_running).to eq 2
      expect(alerter.count_job_retried).to eq 1
      expect(alerter.count_job_canceled).to eq 2
      expect(alerter.count_job_success).to eq 0
      expect(alerter.count_job_failure).to eq 2
    end
  end

  context "when the batch is cleared" do
    subject { details }

    before do
      processor = ActiveJob::Base.method(:execute)
      enqueued_jobs.shift(2).each(&processor)
      batch.abort!
      batch.clear!
    end

    let(:expected_attributes) do
      { size: expected_size,
        enqueued_jobs_count: expected_size,
        pending_jobs_count: 0,
        running_jobs_count: 0,
        total_retries_count: 1,
        successful_jobs_count: 0,
        failed_jobs_count: 1,
        canceled_jobs_count: 0,
        cleared_jobs_count: 2,
        aborted_at: Time.current,
        finished_at: Time.current }
    end

    it { is_expected.to have_attributes expected_attributes }

    it "triggers the right batch callbacks" do
      expect(alerter.count_batch_started).to eq 1
      expect(alerter.count_batch_enqueued).to eq 1
      expect(alerter.count_batch_aborted).to eq 1
      expect(alerter.count_batch_cleared).to eq 1
      expect(alerter.count_batch_finished).to eq 1
    end

    it "triggers the right job callbacks" do
      expect(alerter.count_job_enqueued).to eq 3
      expect(alerter.count_job_running).to eq 2
      expect(alerter.count_job_retried).to eq 1
      expect(alerter.count_job_canceled).to eq 0
      expect(alerter.count_job_success).to eq 0
      expect(alerter.count_job_failure).to eq 2
    end
  end

  context "when all jobs are finished" do
    subject { details }

    before { enqueued_jobs.each(&ActiveJob::Base.method(:execute)) }

    let(:expected_attributes) do
      { size: expected_size,
        enqueued_jobs_count: expected_size,
        pending_jobs_count: 0,
        running_jobs_count: 0,
        total_retries_count: 1,
        successful_jobs_count: 2,
        failed_jobs_count: 1,
        canceled_jobs_count: 0,
        cleared_jobs_count: 0,
        finished_at: Time.current }
    end

    it { is_expected.to have_attributes expected_attributes }

    it "triggers the right batch callbacks" do
      expect(alerter.count_batch_started).to eq 1
      expect(alerter.count_batch_enqueued).to eq 1
      expect(alerter.count_batch_aborted).to eq 0
      expect(alerter.count_batch_cleared).to eq 0
      expect(alerter.count_batch_finished).to eq 1
    end

    it "triggers the right job callbacks" do
      expect(alerter.count_job_enqueued).to eq 3
      expect(alerter.count_job_running).to eq 4
      expect(alerter.count_job_retried).to eq 1
      expect(alerter.count_job_canceled).to eq 0
      expect(alerter.count_job_success).to eq 2
      expect(alerter.count_job_failure).to eq 2
    end
  end
end
