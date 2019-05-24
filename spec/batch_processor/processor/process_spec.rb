# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Process, type: :module do
  include_context "with an example processor", described_class

  describe "#process" do
    subject(:process) { example_processor.process }

    before do
      allow(example_batch).to receive(:start)
      allow(example_processor).to receive(:process_collection)
      allow(example_batch).to receive(:finish)
    end

    context "with unfinished jobs" do
      before { allow(example_batch).to receive(:unfinished_jobs?).and_return(true) }

      it "starts but does not finish the batch" do
        process
        expect(example_batch).to have_received(:start)
        expect(example_processor).to have_received(:process_collection)
        expect(example_batch).not_to have_received(:finish)
      end
    end

    context "without unfinished jobs" do
      it "starts and finishes the batch" do
        process
        expect(example_batch).to have_received(:start)
        expect(example_processor).to have_received(:process_collection)
        expect(example_batch).to have_received(:finish)
      end
    end
  end

  describe "#process_collection" do
    subject { example_processor.process_collection }

    it { is_expected.to be_nil }
  end
end
