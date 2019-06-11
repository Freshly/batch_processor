# frozen_string_literal: true

RSpec.describe ChargeBatch, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::BatchBase }

  describe ".charge_job" do
    subject { described_class.job_class }

    it { is_expected.to eq ChargeJob }
  end
end
