# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Malfunction, type: :module do
  include_context "with an example batch"

  describe "#build_malfunction" do
    subject(:build_malfunction) { example_batch.__send__(:build_malfunction, malfunction_class, context) }

    let(:malfunction_class) { BatchProcessor::Malfunction::CollectionInvalid }
    let(:context) do
      instance_double(BatchProcessor::BatchBase::BatchCollection, errors: double(details: {}, messages: {}))
    end

    it "sets malfunction" do
      expect { build_malfunction }.to change { example_batch.malfunction }.to(instance_of(malfunction_class))

      expect(example_batch.malfunction).to have_attributes(context: context)
    end
  end
end
