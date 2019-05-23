# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Core, type: :module do
  describe "#initialize" do
    include_context "with an example processor"

    it "has a batch" do
      expect(example_processor.batch).to eq example_batch
    end
  end
end
