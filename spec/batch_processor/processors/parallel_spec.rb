# frozen_string_literal: true

RSpec.describe BatchProcessor::Processors::Parallel, type: :processor do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::ProcessorBase }
end
