# frozen_string_literal: true

class TrafficLightBatch < BatchProcessor::BatchBase
  with_sequential_processor
  processor_option :continue_after_exception, true

  def build_collection
    %w[green yellow red]
  end
end
