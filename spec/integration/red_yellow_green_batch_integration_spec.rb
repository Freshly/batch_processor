# frozen_string_literal: true

RSpec.describe RedYellowGreenBatch, type: :integration do
  subject(:process) { batch.process }

  let(:enqueued_jobs) { ActiveJob::Base.queue_adapter.enqueued_jobs }
  let(:batch) { described_class.new }
  let(:details) { batch.details }
  let(:expected_size) { batch.collection_items.count }

  before { process }

  shared_examples_for "the light is processed" do |index, result|
    it "processes the light" do
      expect { ActiveJob::Base.execute enqueued_jobs[index] }.
        to change { details.pending_jobs_count }.by(-1).
        and change { details.public_send(result) }.by(1).
        and change { details.finished_jobs_count }.by(1)
    end
  end

  it_behaves_like "the light is processed", 0, :failed_jobs_count
  it_behaves_like "the light is processed", 2, :successful_jobs_count

  it "processes the retry" do
    expect { ActiveJob::Base.execute enqueued_jobs[1] }.to change { details.total_retries_count }.by(1)
    expect { ActiveJob::Base.execute enqueued_jobs.last }.
      to change { details.pending_jobs_count }.by(-1).
      and change { details.successful_jobs_count }.by(1).
      and change { details.finished_jobs_count }.by(1)
  end

  it "processes the batch fully" do
    expect { enqueued_jobs.each(&ActiveJob::Base.method(:execute)) }.
      to change { details.pending_jobs_count }.by(-expected_size).
      and change { details.total_retries_count }.by(1).
      and change { details.successful_jobs_count }.by(2).
      and change { details.failed_jobs_count }.by(1).
      and change { details.finished_jobs_count }.by(expected_size).
      and change { details.finished_at }.from(nil).to(Time.current).
      and change { batch.finished? }.from(false).to(true)
  end
end
