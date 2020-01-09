# frozen_string_literal: true

RSpec.describe BatchProcessor::Malfunction::Base, type: :malfunction do
  subject { described_class }

  it { is_expected.to inherit_from Malfunction::MalfunctionBase }

  it { is_expected.to have_prototype_name "Base" }
  it { is_expected.to have_conjunction_prefix "BatchProcessor::Malfunction::" }
  it { is_expected.to have_conjunction_suffix nil }
  it { is_expected.to have_junction_key :batch_processor_malfunction }
end
