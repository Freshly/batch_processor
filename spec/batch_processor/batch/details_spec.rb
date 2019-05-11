# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Details, type: :module do
  include_context "with an example batch", described_class

  describe "#details" do
    subject { example_batch.details }

    it { is_expected.to be_an_instance_of BatchProcessor::BatchDetails }
  end
end
