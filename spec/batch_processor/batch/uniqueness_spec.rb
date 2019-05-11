# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Uniqueness, type: :module do
  include_context "with an example batch", described_class

  context "with existing batch" do
    before { Redis.new.hset("BatchProcessor:#{id}", "key", "value") }

    context "with input" do
      let(:input) { Hash[*Faker::Lorem.words(2 * rand(1..2))].symbolize_keys }

      it "raises" do
        expect { example_batch }.to raise_error BatchProcessor::ExistingBatchError
      end
    end

    context "without input" do
      it "does not raise" do
        expect { example_batch }.not_to raise_error
      end
    end
  end
end
