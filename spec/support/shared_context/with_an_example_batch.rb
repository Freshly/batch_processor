# frozen_string_literal: true

RSpec.shared_context "with an example batch" do
  subject(:example_batch) { example_batch_class.new(batch_id: batch_id, **input) }

  let(:example_batch_class) { Class.new(BatchProcessor::BatchBase) }
  let(:example_collection_class) { Class.new(example_batch_class::BatchCollection) }

  let(:batch_id) { SecureRandom.hex }
  let(:input) do
    {}
  end

  let(:root_name) { Faker::Internet.domain_word.capitalize }
  let(:example_batch_name) { "#{root_name}Batch" }

  before do
    stub_const(example_batch_name, example_batch_class)
    stub_const("#{example_batch_name}::Collection", example_collection_class)
  end
end
