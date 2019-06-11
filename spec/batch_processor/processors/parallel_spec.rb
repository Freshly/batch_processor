# frozen_string_literal: true

RSpec.describe BatchProcessor::Processors::Parallel, type: :processor do
  include_context "with an example batch"

  subject { described_class }

  let(:collection) do
    Array.new(3) { Hash[*Faker::Lorem.words(2)] }
  end
  let(:job_class) { Class.new(BatchProcessor::BatchJob) }

  before do
    allow(example_batch).to receive(:collection).and_return(collection)
    allow(example_batch).to receive(:job_class).and_return(job_class)
    allow(job_class).to receive(:perform_later)
  end

  it { is_expected.to inherit_from BatchProcessor::ProcessorBase }

  describe "#process_collection_item" do
    subject(:execute) { described_class.execute(batch: example_batch) }

    it "processes the collection in order" do
      execute
      collection.each { |item| expect(job_class).to have_received(:perform_later).with(item).ordered }
    end
  end

  describe ".collection_processed callback" do
    subject(:execute) { described_class.execute(batch: example_batch) }

    it "marks the batch as enqueued" do
      expect { execute }.to change { example_batch.enqueued? }.from(false).to(true)
    end
  end
end
