# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Process, type: :module do
  include_context "with an example processor"

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
    subject(:process_collection) { example_processor.__send__(:process_collection) }

    let(:expected_collection) { %i[a b c] }

    before do
      allow(example_batch).to receive(:collection).and_return(collection)
      allow(example_processor).to receive(:process_collection_item)
    end

    shared_examples_for "the collection is processed" do
      before { allow(example_processor).to receive(:process_collection_item) }

      it "processes all items" do
        process_collection
        expected_collection.each do |item|
          expect(example_processor).to have_received(:process_collection_item).with(item).ordered
        end
      end
    end

    context "with collection#find_each method" do
      before { allow(collection).to receive(:find_each).and_call_original }

      let(:collection) { collection_class.new(expected_collection) }

      let(:collection_class) do
        Class.new do
          attr_reader :array

          def initialize(array)
            @array = array
          end

          def find_each(&block)
            array.each(&block)
          end
        end
      end

      it_behaves_like "the collection is processed"
    end

    context "without collection#find_each method" do
      let(:collection) { expected_collection }

      it_behaves_like "the collection is processed"
    end
  end
end
