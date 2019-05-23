# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Process, type: :module do
  include_context "with an example processor", described_class

  describe "#process" do
    subject(:process) { example_processor.process }

    before { allow(example_batch).to receive(:start) }

    it "starts the batch" do
      process
      expect(example_batch).to have_received(:start)
    end
  end
end
