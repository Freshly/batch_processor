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

  describe described_class::AlreadyStartedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyStarted" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::AlreadyStarted }
  end

  describe described_class::AlreadyEnqueuedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it {is_expected.to have_prototype_name "AlreadyEnqueued" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::AlreadyEnqueued }
  end

  describe described_class::AlreadyAbortedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyAborted" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::AlreadyAborted }
  end

  describe described_class::AlreadyClearedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyCleared" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::AlreadyCleared }
  end

  describe described_class::AlreadyFinishedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "AlreadyFinished" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::AlreadyFinished }
  end

  describe described_class::StillProcessingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "StillProcessing" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::StillProcessing }
  end

  describe described_class::NotProcessingError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "NotProcessing" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::NotProcessing }
  end

  describe described_class::NotAbortedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "NotAborted" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::NotAborted }
  end

  describe described_class::NotStartedError do
    it { is_expected.to inherit_from BatchProcessor::Error }
    it { is_expected.to have_prototype_name "NotStarted" }
    it { is_expected.to conjugate_into BatchProcessor::Malfunction::NotStarted }
  end
end
