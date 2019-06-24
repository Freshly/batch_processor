# frozen_string_literal: true

RSpec.describe InheritedEmptyBatch, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchBase }
  it { is_expected.to be_allow_empty }
end
