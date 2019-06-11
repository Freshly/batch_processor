# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Collection, type: :module do
  include_context "with an example batch"

  describe "#collection" do
    subject { example_batch.collection }

    let(:collection) { double }

    before { allow(example_batch).to receive(:build_collection).and_return(collection) }

    it { is_expected.to eq collection }
  end

  describe "#build_collection" do
    subject { example_batch.build_collection }

    it { is_expected.to eq [] }
  end

  describe "#collection_item_to_job_params" do
    subject { example_batch.collection_item_to_job_params(item) }

    let(:item) { double }

    it { is_expected.to eq item}
  end
end
