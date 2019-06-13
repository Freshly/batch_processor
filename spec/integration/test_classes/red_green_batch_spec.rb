# frozen_string_literal: true

RSpec.describe RedGreenBatch, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchBase }
  it { is_expected.to use_default_job_class }
  it { is_expected.to use_parallel_processor }
  it { is_expected.to be_allow_empty }

  describe RedGreenBatch::Collection, type: :batch_collection do
    subject { described_class.new(color: :red) }

    it { is_expected.to inherit_from BatchProcessor::BatchBase::BatchCollection }
    it { is_expected.to define_argument :color, allow_nil: false }
    it { is_expected.to define_option :collection_size, default: 3 }
    it { is_expected.to validate_inclusion_of(:color).in_array(%w[red green]) }
  end
end
