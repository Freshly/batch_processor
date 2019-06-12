# frozen_string_literal: true

RSpec.describe CustomJob, type: :batch_job do
  it { is_expected.to inherit_from BatchProcessor::BatchJob }
end
