# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Details::Status, type: :module do
  include_context "with example details", described_class

  describe "#started?" do
    it { is_expected.not_to be_started }
  end

  describe "#finished?" do
    it { is_expected.not_to be_finished }
  end
end
