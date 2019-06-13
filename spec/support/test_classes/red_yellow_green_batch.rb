# frozen_string_literal: true

class RedYellowGreenBatch < BatchProcessor::BatchBase
  with_parallel_processor
  process_with_job TrafficLightJob

  class Collection < BatchCollection
    def items
      %w[red yellow green]
    end
  end
end
