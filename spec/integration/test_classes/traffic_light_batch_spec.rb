# frozen_string_literal: true

RSpec.describe TrafficLightBatch, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchBase }
  it { is_expected.to use_default_job_class }
  it { is_expected.to use_sequential_processor }
  it { is_expected.to set_processor_option :sorted, true }
  it { is_expected.not_to be_allow_empty }
end
