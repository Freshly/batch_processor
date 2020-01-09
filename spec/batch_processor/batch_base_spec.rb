# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchBase, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from Spicerack::InputObject }

  it { is_expected.to include_module Conjunction::Junction }
  it { is_expected.to have_conjunction_suffix "Batch" }
  it { is_expected.to have_junction_key :batch }

  it { is_expected.to include_module BatchProcessor::Batch::Core }
  it { is_expected.to include_module BatchProcessor::Batch::Job }
  it { is_expected.to include_module BatchProcessor::Batch::Malfunction }
  it { is_expected.to include_module BatchProcessor::Batch::Processor }
  it { is_expected.to include_module BatchProcessor::Batch::Predicates }
  it { is_expected.to include_module BatchProcessor::Batch::Controller }
  it { is_expected.to include_module BatchProcessor::Batch::JobController }

  describe BatchProcessor::BatchBase::BatchCollection do
    it { is_expected.to inherit_from Spicerack::InputModel }
  end

  describe BatchProcessor::BatchBase::Collection do
    it { is_expected.to inherit_from BatchProcessor::BatchBase::BatchCollection }
  end
end
