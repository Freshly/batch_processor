# frozen_string_literal: true

RSpec.describe DefaultBatch, type: :batch do
  it { is_expected.to inherit_from BatchProcessor::BatchBase }
  it { is_expected.to use_job_class CustomJob }
  it { is_expected.to use_default_processor }
  it { is_expected.not_to be_allow_empty }
end
