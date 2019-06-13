# frozen_string_literal: true

RSpec.describe BatchProcessor::Processors::Parallel, type: :processor do
  include_context "with an example processor batch"

  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::ProcessorBase }

  describe "#process_collection_item" do
    subject(:execute) { described_class.execute(batch: example_batch) }

    it "processes the collection in order" do
      execute

      collection_items.each do |item|
        expect(job_class).to have_received(:new).with(item).ordered
        expect(collection_instances[item].batch_id).to eq example_batch.batch_id
        expect(collection_instances[item]).to have_received(:enqueue).ordered
      end
    end
  end

  describe ".collection_processed callback" do
    subject(:execute) { described_class.execute(batch: example_batch) }

    it "marks the batch as enqueued" do
      expect { execute }.to change { example_batch.enqueued? }.from(false).to(true)
    end
  end
end
