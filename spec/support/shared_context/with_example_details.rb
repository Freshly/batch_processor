# frozen_string_literal: true

RSpec.shared_context "with example details" do |extra_details_modules = nil|
  subject(:example_details) { example_details_class.new(batch_id) }

  let(:root_details_modules) do
    [ ShortCircuIt, Technologic, BatchProcessor::Batch::Details::Callbacks, BatchProcessor::Batch::Details::Core ]
  end
  let(:details_modules) { root_details_modules + Array.wrap(extra_details_modules) }

  let(:root_details_class) { Class.new }
  let(:example_details_class) do
    root_details_class.tap do |details_class|
      details_modules.each { |details_module| details_class.include details_module }
    end
  end

  let(:batch_id) { SecureRandom.hex }
end
