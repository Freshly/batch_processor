# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Execute, type: :module do
  include_context "with an example processor", [ BatchProcessor::Processor::Process, described_class ]

  describe ".execute" do
    it_behaves_like "a class pass method", :execute do
      let(:test_class) { example_processor_class }
      let(:call_class) { example_processor_class }
    end
  end

  describe "#execute" do
    subject(:execute) { example_processor.execute }

    before do
      allow(example_processor).to receive(:surveil).and_call_original
      allow(example_processor).to receive(:process)
    end

    it_behaves_like "a class with callback" do
      include_context "with callbacks", :execute

      subject(:callback_runner) { execute }

      let(:example) { example_processor }
      let(:example_class) { example.class }
    end

    it "is surveiled" do
      execute
      expect(example_processor).to have_received(:surveil).with(:execute)
      expect(example_processor).to have_received(:process)
    end
  end
end
