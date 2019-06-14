# frozen_string_literal: true

RSpec.describe TrafficLightBatch, type: :integration do
  subject(:process) { batch.process }

  let(:batch) { described_class.new }
  let(:details) { batch.details }

  it "fails the retry use case as processor disallows it" do
    expect { process }.
      to change { details.total_retries_count }.by(0).
      and change { details.successful_jobs_count }.by(1).
      and change { details.failed_jobs_count }.by(2).
      and change { details.total_jobs_count }.by(3).
      and change { details.finished_jobs_count }.by(3)
  end
end
