# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Core, type: :module do
  describe "#initialize" do
    include_context "with example class having callback", :initialize

    subject(:instance) { example_processor_class.new(example_batch, **processor_options) }

    let(:example_processor_class) do
      Class.new(example_class_having_callback).tap { |klass| klass.include described_class }
    end

    let(:example_batch) { instance_double(BatchProcessor::BatchBase) }
    let(:processor_options) { Hash[*Faker::Lorem.words(2 * rand(1..2))].symbolize_keys }

    it "has a batch" do
      expect(instance.batch).to eq example_batch
    end

    it "has options" do
      expect(instance.options).to eq processor_options
    end

    it_behaves_like "a class with callback" do
      subject(:callback_runner) { instance }

      let(:example) { example_processor_class }
    end
  end
end
