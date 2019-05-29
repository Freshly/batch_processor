# frozen_string_literal: true

RSpec.shared_context "with an example batch" do |extra_batch_modules = nil|
  subject(:example_batch) { example_batch_class.new(id, **input) }

  let(:root_batch_modules) { [ BatchProcessor::Batch::Callbacks, BatchProcessor::Batch::Core ] }
  let(:batch_modules) { root_batch_modules + Array.wrap(extra_batch_modules) }

  let(:root_batch_class) { Class.new(Spicerack::InputModel) }
  let(:example_batch_class) do
    root_batch_class.tap do |batch_class|
      batch_modules.each { |batch_module| batch_class.include batch_module }
    end
  end

  let(:id) { SecureRandom.hex }
  let(:input) do
    {}
  end
end
