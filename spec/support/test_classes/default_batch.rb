# frozen_string_literal: true

class DefaultBatch < BatchProcessor::BatchBase
  process_with_job CustomJob
end
