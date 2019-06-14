# frozen_string_literal: true

RSpec.describe BatchProcessor do
  it "has a version number" do
    expect(BatchProcessor::VERSION).not_to be nil
  end

  describe described_class::Error do
    it { is_expected.to inherit_from StandardError }
  end

  describe described_class::Error do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::NotFoundError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::ClassMissingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::CollectionEmptyError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::CollectionInvalidError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::AlreadyExistsError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::AlreadyStartedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::AlreadyEnqueuedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::AlreadyAbortedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::AlreadyClearedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::AlreadyFinishedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::StillProcessingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::NotProcessingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::NotAbortedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::NotStartedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end
end
