# frozen_string_literal: true

RSpec.describe BatchProcessor::Collection, type: :collection do
  it { is_expected.to inherit_from Spicerack::InputModel }

  let(:example_collection) { example_collection_class.new }
  let(:example_collection_class) { Class.new(described_class) }

  describe "#items" do
    subject { example_collection.items }

    it { is_expected.to eq [] }
  end

  describe "#item_to_job_params" do
    subject { example_collection.item_to_job_params(item) }

    let(:item) { double }

    it { is_expected.to eq item }
  end
end
