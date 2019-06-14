# frozen_string_literal: true

class TrafficLightBatch < BatchProcessor::BatchBase
  with_sequential_processor
  processor_option :sorted, true

  class Collection < BatchCollection
    def items
      %w[green yellow red]
    end
  end
end
