# frozen_string_literal: true

RSpec.shared_context "with an example processor" do
  subject(:example_processor) { example_processor_class.new(batch: example_batch, **processor_options) }

  let(:example_processor_class) { Class.new(BatchProcessor::ProcessorBase) }

  let(:batch_id) { SecureRandom.hex }
  let(:processor_options) { {} }
  let(:example_batch) { example_batch_class.new(batch_id) }
  let(:example_batch_class) { Class.new(BatchProcessor::BatchBase) }
end
