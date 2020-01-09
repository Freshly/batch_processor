# frozen_string_literal: true

RSpec.describe BatchProcessor do
  it "has a version number" do
    expect(BatchProcessor::VERSION).not_to be nil
  end

  describe described_class::Error do
    subject { described_class }

    it { is_expected.to inherit_from StandardError }
    it { is_expected.to include_module Conjunction::Junction }
    it { is_expected.to have_conjunction_prefix "BatchProcessor::" }
    it { is_expected.to have_conjunction_suffix "Error" }
    it { is_expected.to have_junction_key :batch_processor_error }
  end

  describe described_class::Error do
    it { is_expected.to inherit_from BatchProcessor::Error }
  end

  describe described_class::NotFoundError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "NotFound" }
  end

  describe described_class::ClassMissingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "ClassMissing" }
  end

  describe described_class::CollectionEmptyError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "CollectionEmpty" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::CollectionEmpty }
  end

  describe described_class::CollectionInvalidError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "CollectionInvalid" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::CollectionInvalid }
  end

  describe described_class::AlreadyExistsError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyExists" }
  end

  describe described_class::AlreadyStartedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyStarted" }
  end

  describe described_class::AlreadyEnqueuedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it {is_expected.to have_prototype_name "AlreadyEnqueued" }
  end

  describe described_class::AlreadyAbortedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyAborted" }
  end

  describe described_class::AlreadyClearedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyCleared" }
  end

  describe described_class::AlreadyFinishedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyFinished" }
  end

  describe described_class::StillProcessingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "StillProcessing" }
  end

  describe described_class::NotProcessingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "NotProcessing" }
  end

  describe described_class::NotAbortedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "NotAborted" }
  end

  describe described_class::NotStartedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "NotStarted" }
  end
end
