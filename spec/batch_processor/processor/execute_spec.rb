# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Execute, type: :module do
  include_context "with an example processor", described_class

  describe "#execute" do
    subject(:execute) { example_processor.execute }

    context "without a batch collection" do
      it "raises" do
        expect { execute }.to raise_error BatchProcessor::BatchEmptyError
      end
    end

    context "with a batch collection" do
      before do
        allow(example_processor).to receive(:surveil).and_call_original
        allow(batch).to receive(:collection).and_return(Faker::Lorem.words)
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
      end
    end
  end
end
