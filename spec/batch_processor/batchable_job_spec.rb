# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchableJob, type: :job do
  subject(:job_class) { described_class }

  it { is_expected.to inherit_from ActiveJob::Base }
end
