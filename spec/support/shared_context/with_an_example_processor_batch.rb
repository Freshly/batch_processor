# frozen_string_literal: true

RSpec.shared_context "with an example processor batch" do
  include_context "with an example batch"

  subject { described_class }

  let(:collection) do
    Array.new(3) { Hash[*Faker::Lorem.words(2)] }
  end
  let(:job_class) { Class.new(BatchProcessor::BatchJob) }
  let!(:collection_instances) do
    collection.each_with_object({}) do |item, hash|
      instance = job_class.new(item)
      allow(instance).to receive(:enqueue)
      allow(instance).to receive(:perform_now)
      hash[item] = instance
    end
  end

  before do
    allow(example_batch).to receive(:collection).and_return(collection)
    allow(example_batch).to receive(:job_class).and_return(job_class)
    allow(job_class).to(receive(:new)) { |item| collection_instances[item] }
  end
end
