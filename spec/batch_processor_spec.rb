# frozen_string_literal: true

RSpec.describe BatchProcessor do
  it "has a version number" do
    expect(BatchProcessor::VERSION).not_to be nil
  end

  describe described_class::Error do
    it { is_expected.to inherit_from StandardError }
  end

  describe described_class::ExistingBatchError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end
end
