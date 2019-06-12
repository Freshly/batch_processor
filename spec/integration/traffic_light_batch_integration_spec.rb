# frozen_string_literal: true

RSpec.describe TrafficLightBatch, type: :integration do
  subject(:process) { batch.process }

  let(:enqueued_jobs) { ActiveJob::Base.queue_adapter.enqueued_jobs }
  let(:batch) { described_class.new }
  let(:details) { batch.details }
  let(:expected_size) { batch.collection.count }

  # before { process }

  # it_behaves_like "the batch is started and enqueued"
  # it_behaves_like "the counts are expected"

  # it "does" do
  #   puts enqueued_jobs
  # end

  it "retries the yellow light" do
    expect { process }.
      to change { details.total_retries_count }.by(1).
      and change { details.successful_jobs_count }.by(1).
      and change { details.failed_jobs_count }.by(1).
      and change { details.total_jobs_count }.by(3).
      and change { details.finished_jobs_count }.by(2)
  end
end
