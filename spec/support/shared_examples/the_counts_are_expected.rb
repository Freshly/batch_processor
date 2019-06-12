# frozen_string_literal: true

RSpec.shared_examples_for "the counts are expected" do
  subject { details }

  let(:expected_attributes) do
    { size: expected_size,
      enqueued_jobs_count: expected_size,
      pending_jobs_count: expected_size,
      running_jobs_count: 0,
      total_retries_count: 0,
      successful_jobs_count: 0,
      failed_jobs_count: 0,
      canceled_jobs_count: 0,
      cleared_jobs_count: 0 }
  end

  it { is_expected.to have_attributes expected_attributes }

  describe "#total_jobs_count" do
    subject { details.total_jobs_count }

    it { is_expected.to eq expected_size }
  end
end
