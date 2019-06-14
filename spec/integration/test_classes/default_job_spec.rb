# frozen_string_literal: true

RSpec.describe DefaultJob, type: :batch_job do
  it { is_expected.to inherit_from BatchProcessor::BatchJob }
end
