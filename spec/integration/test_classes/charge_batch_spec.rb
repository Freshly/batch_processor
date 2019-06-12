# frozen_string_literal: true

RSpec.describe ChargeBatch, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchBase }
  it { is_expected.to use_parallel_processor }
  it { is_expected.to be_allow_empty }
  it { is_expected.to define_argument :charge_day, allow_nil: false }

  describe ".charge_job" do
    subject { described_class.job_class }

    it { is_expected.to eq ChargeJob }
  end
end
