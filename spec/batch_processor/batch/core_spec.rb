# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Core, type: :module do
  describe "#initialize" do
    include_context "with an example batch"

    before { example_batch_class.__send__(:option, :test_attribute1) }

    let(:id) { SecureRandom.hex }
    let(:input) do
      { test_attribute1: :test_value1 }
    end

    shared_examples_for "an instance" do
      let(:expected_id) { :default }
      let(:expected_input) { {} }

      it "has an id always" do
        if expected_id == :default
          expect(example_batch.id).not_to be_nil
        else
          expect(example_batch.id).to eq expected_id
        end
      end

      it "defines details" do
        expect(example_batch.details).to be_an_instance_of BatchProcessor::BatchDetails
        expect(example_batch.details.batch_id).to eq example_batch.id
      end

      it "stores input" do
        expect(example_batch.input).to eq expected_input
      end
    end

    context "with no arguments" do
      subject(:example_batch) { example_batch_class.new }

      it_behaves_like "an instance"
    end

    context "with only an id" do
      subject(:example_batch) { example_batch_class.new(id) }

      it_behaves_like "an instance" do
        let(:expected_id) { id }
      end
    end

    context "with only input" do
      subject(:example_batch) { example_batch_class.new(**input) }

      it_behaves_like "an instance" do
        let(:expected_input) { input }
      end
    end

    context "with id and input" do
      subject(:example_batch) { example_batch_class.new(id, **input) }

      context "with existing batch" do
        before { Redis.new.hset("BatchProcessor:#{id}", "key", "value") }

        it "raises" do
          expect { example_batch }.to raise_error BatchProcessor::ExistingBatchError
        end
      end

      context "without existing batch" do
        it_behaves_like "an instance" do
          let(:expected_id) { id }
          let(:expected_input) { input }
        end
      end
    end
  end
end
