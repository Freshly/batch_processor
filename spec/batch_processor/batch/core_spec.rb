# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Core, type: :module do
  describe "#initialize" do
    include_context "with example class having callback", :initialize

    subject(:instance) { example_class.new(**arguments) }

    let(:arguments) { Hash[*Faker::Lorem.words(4)].symbolize_keys }
    let(:example_class) { example_class_having_callback.include(described_class) }

    it "stores input" do
      expect(instance.input).to eq arguments
    end

    it_behaves_like "a class with callback" do
      subject(:callback_runner) { instance }

      let(:example) { example_class }
    end
  end
end
