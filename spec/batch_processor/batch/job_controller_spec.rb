# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::JobController, type: :module do
  include_context "with an example batch", [
    BatchProcessor::Batch::Collection,
    BatchProcessor::Batch::Predicates,
    described_class,
  ]
end
