# frozen_string_literal: true

RSpec.describe BatchProcessor::Processors::Parallel, type: :processor do
  subject { described_class }

  let(:batch) { instance_double(BatchProcessor::BatchBase) }
  let(:collection) { [] }

  before do
    allow(batch).to receive(:start)
    allow(batch).to receive(:collection).and_return(collection)
    allow(batch).to receive(:unfinished_jobs?).and_return(true)
    allow(batch).to receive(:enqueued)
  end

  it { is_expected.to inherit_from BatchProcessor::ProcessorBase }

  describe "#process_collection_item" do
    subject(:execute) { described_class.execute(batch: batch) }

    let(:collection) do
      Array.new(2) { Hash[*Faker::Lorem.words(2)] }
    end
    let(:job_class) { Class.new(BatchProcessor::BatchJob) }

    before do
      allow(batch).to receive(:job_class).and_return(job_class)
      allow(job_class).to receive(:perform_later)
    end

    it "marks the batch as enqueued" do
      execute
      collection.each { |item| expect(job_class).to have_received(:perform_later).with(item).ordered }
    end
  end

  describe ".collection_processed callback" do
    subject(:execute) { described_class.execute(batch: batch) }

    before { allow(batch).to receive(:enqueued) }

    it "marks the batch as enqueued" do
      execute
      expect(batch).to have_received(:enqueued)
    end
  end
end
