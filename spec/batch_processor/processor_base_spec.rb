# frozen_string_literal: true

RSpec.describe BatchProcessor::ProcessorBase, type: :processor do
  subject { described_class }

  it { is_expected.to include_module Technologic }
  it { is_expected.to include_module Tablesalt::Dsl::Defaults }
  it { is_expected.to include_module BatchProcessor::Processor::Callbacks }
  it { is_expected.to include_module BatchProcessor::Processor::Options }
  it { is_expected.to include_module BatchProcessor::Processor::Core }
  it { is_expected.to include_module BatchProcessor::Processor::Process }
  it { is_expected.to include_module BatchProcessor::Processor::Execute }
end
