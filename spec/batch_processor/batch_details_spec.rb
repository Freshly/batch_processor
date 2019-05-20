# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchDetails, type: :batch do
  subject { described_class }

  let(:instance) { described_class.new(batch_id) }
  let(:batch_id) { SecureRandom.hex }

  it { is_expected.to inherit_from RedisHash::Base }
  it { is_expected.to include_module Tablesalt::HashModel }

  describe "#hash" do
    subject(:hash) { instance.hash }

    it { is_expected.to be_a described_class }
  end
end
