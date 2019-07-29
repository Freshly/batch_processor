# frozen_string_literal: true

RSpec.describe DefaultBatch, type: :integration do
  context "without any arguments" do
    subject(:process!) { described_class.process! }

    it "raises" do
      expect { process! }.to raise_error BatchProcessor::CollectionEmptyError
    end
  end
end
