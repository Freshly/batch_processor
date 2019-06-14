# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchBase, type: :integration do
  describe ".process_with_job" do
    let(:define_class) do
      Class.new(described_class) do
        process_with_job String
      end
    end

    it "raises an error if your class definition is invalid" do
      expect { define_class }.to raise_error ArgumentError, "Unbatchable job"
    end
  end
end
