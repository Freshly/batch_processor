# frozen_string_literal: true

RSpec.describe BatchProcessor do
  it "has a version number" do
    expect(BatchProcessor::VERSION).not_to be nil
  end

  describe described_class::Error do
    it { is_expected.to inherit_from StandardError }
  end

  describe described_class::BatchError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::ProcessorError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::ExistingBatchError do
    it { is_expected.to inherit_from BatchProcessor::BatchError }
  end

  describe described_class::BatchEmptyError do
    it { is_expected.to inherit_from BatchProcessor::BatchError }
  end

  describe described_class::BatchAlreadyStartedError do
    it { is_expected.to inherit_from BatchProcessor::BatchError }
  end

  describe described_class::BatchAlreadyFinishedError do
    it { is_expected.to inherit_from BatchProcessor::BatchError }
  end

  describe described_class::BatchAlreadyEnqueuedError do
    it { is_expected.to inherit_from BatchProcessor::BatchError }
  end

  describe described_class::BatchStillProcessingError do
    it { is_expected.to inherit_from BatchProcessor::BatchError }
  end

  describe described_class::BatchNotProcessingError do
    it { is_expected.to inherit_from BatchProcessor::BatchError }
  end
end
