# frozen_string_literal: true

class RedGreenBatch < BatchProcessor::BatchBase
  allow_empty
  with_parallel_processor

  argument :color, allow_nil: false
  option :collection_size, default: 3

  def build_collection
    Array.new(collection_size) { color }
  end
end
