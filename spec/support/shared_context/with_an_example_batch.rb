# frozen_string_literal: true

RSpec.shared_context "with an example batch" do
  subject(:example_batch) { example_batch_class.new(batch_id: id, **input) }

  let(:example_batch_class) { Class.new(BatchProcessor::BatchBase) }

  let(:id) { SecureRandom.hex }
  let(:input) do
    {}
  end
end
