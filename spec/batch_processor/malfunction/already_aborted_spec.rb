# frozen_string_literal: true

RSpec.describe BatchProcessor::Malfunction::AlreadyAborted, type: :malfunction do
  subject(:malfunction) { described_class.new }

  it { is_expected.to inherit_from BatchProcessor::Malfunction::Base }

  it { is_expected.to have_prototype_name "AlreadyAborted" }
  it { is_expected.to conjugate_into BatchProcessor::AlreadyAbortedError }

  it { is_expected.not_to use_attribute_errors }
  it { is_expected.not_to be_contextualized }
  it { is_expected.to have_default_problem }
end
