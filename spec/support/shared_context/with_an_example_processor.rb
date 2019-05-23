# frozen_string_literal: true

RSpec.shared_context "with an example processor" do |extra_processor_modules = nil|
  subject(:example_processor) { example_processor_class.new(batch) }

  let(:root_processor_modules) do
    [ Technologic, BatchProcessor::Processor::Callbacks, BatchProcessor::Processor::Core ]
  end
  let(:batch_modules) { root_processor_modules + Array.wrap(extra_processor_modules) }

  let(:root_processor_class) { Class.new }
  let(:example_processor_class) do
    root_processor_class.tap do |batch_class|
      batch_modules.each { |batch_module| batch_class.include batch_module }
    end
  end

  let(:batch) { batch_class.new }
  let(:batch_class) { Class.new(BatchProcessor::BatchBase) }
end
