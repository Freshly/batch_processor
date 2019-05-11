# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Details::Core, type: :module do
  describe "#initialize" do
    include_context "with example class having callback", :initialize

    subject(:instance) { example_class.new(batch_id) }

    let(:batch_id) { SecureRandom.hex }
    let(:example_class) { example_class_having_callback.include(described_class) }

    it "stores batch_id" do
      expect(instance.batch_id).to eq batch_id
    end
  end
end
