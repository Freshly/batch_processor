# frozen_string_literal: true

RSpec.describe StopOrGoBatch, type: :integration do
  subject(:process) { batch.process }

  let(:batch) { described_class.new }
  let(:details) { batch.details }

  it "stops on failure" do
    expect { process }.
      to raise_error(StandardError).
      and change { details.total_retries_count }.by(0).
      and change { details.successful_jobs_count }.by(1).
      and change { details.failed_jobs_count }.by(1).
      and change { details.finished_jobs_count }.by(2)
  end
end
