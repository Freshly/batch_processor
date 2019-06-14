# frozen_string_literal: true

RSpec.describe RedYellowGreenBatch, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchBase }
  it { is_expected.to use_job_class TrafficLightJob }
  it { is_expected.to use_parallel_processor }
  it { is_expected.not_to be_allow_empty }
end
