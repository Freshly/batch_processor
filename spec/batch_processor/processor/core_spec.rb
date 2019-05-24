# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Core, type: :module do
  describe "#initialize" do
    include_context "with an example processor"

    let(:processor_options) { Hash[*Faker::Lorem.words(2 * rand(1..2))].symbolize_keys }

    it "has a batch" do
      expect(example_processor.batch).to eq example_batch
    end

    it "has options" do
      expect(example_processor.options).to eq processor_options
    end
  end
end
