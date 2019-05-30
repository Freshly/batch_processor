# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Execute, type: :module do
  include_context "with an example processor"

  describe ".execute" do
    it_behaves_like "a class pass method", :execute do
      let(:test_class) { example_processor_class }
      let(:call_class) { example_processor_class }
    end
  end

  describe "#execute" do
    subject(:execute) { example_processor.execute }

    before { allow(example_processor).to receive(:process) }

    it_behaves_like "a class with callback" do
      include_context "with callbacks", :execute

      subject(:callback_runner) { execute }

      let(:example) { example_processor }
      let(:example_class) { example.class }
    end

    it_behaves_like "a surveiled event", :execute do
      let(:expected_class) { example_processor_class.name }

      before { execute }
    end
  end
end
