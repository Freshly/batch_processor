# frozen_string_literal: true

RSpec.describe TrafficLightJob, type: :batch_job do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchJob }
end
