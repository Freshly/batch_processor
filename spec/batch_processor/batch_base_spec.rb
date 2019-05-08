# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchBase, type: :batch do
  it { is_expected.to include_module Technologic }
  it { is_expected.to include_module BatchProcessor::Batch::Callbacks }
  it { is_expected.to include_module BatchProcessor::Batch::Core }
end
