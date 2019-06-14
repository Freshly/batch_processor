# frozen_string_literal: true

RSpec.describe AlwaysGoBatch, type: :integration do
  subject(:process) { batch.process }

  let(:batch) { described_class.new }
  let(:details) { batch.details }

  it "stops on failure" do
    expect { process }.
      to change { details.successful_jobs_count }.by(1).
      and change { details.failed_jobs_count }.by(2).
      and change { details.finished_jobs_count }.by(3)
  end
end
