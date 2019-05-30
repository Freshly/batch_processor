# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Collection, type: :module do
  include_context "with an example batch"

  describe "#collection" do
    subject { example_batch.collection }

    it { is_expected.to eq [] }
  end
end
