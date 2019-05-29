# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchBase, type: :batch do
  it { is_expected.to inherit_from Spicerack::InputModel }

  it { is_expected.to include_module BatchProcessor::Batch::Callbacks }
  it { is_expected.to include_module BatchProcessor::Batch::Core }
  it { is_expected.to include_module BatchProcessor::Batch::Collection }
  it { is_expected.to include_module BatchProcessor::Batch::Job }
  it { is_expected.to include_module BatchProcessor::Batch::Processor }
  it { is_expected.to include_module BatchProcessor::Batch::Predicates }
  it { is_expected.to include_module BatchProcessor::Batch::Controller }
end
