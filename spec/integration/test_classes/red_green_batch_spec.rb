# frozen_string_literal: true

RSpec.describe RedGreenBatch, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchBase }
  it { is_expected.to use_parallel_processor }
  it { is_expected.to be_allow_empty }
  it { is_expected.to define_argument :color, allow_nil: false }
  it { is_expected.to define_option :collection_size, default: 3 }

  describe ".job_class" do
    subject { described_class.job_class }

    it { is_expected.to eq RedGreenJob }
  end
end
