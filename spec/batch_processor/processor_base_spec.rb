# frozen_string_literal: true

RSpec.describe BatchProcessor::ProcessorBase, type: :processor do
  subject { described_class }

  it { is_expected.to inherit_from Spicerack::InputObject }
  it { is_expected.to include_module BatchProcessor::Processor::Process }
  it { is_expected.to include_module BatchProcessor::Processor::Execute }

  it { is_expected.to define_argument :batch, allow_nil: false }
end
