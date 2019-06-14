# frozen_string_literal: true

class StopOrGoBatch < BatchProcessor::BatchBase
  with_sequential_processor

  class Collection < BatchCollection
    def items
      %w[green yellow red]
    end
  end
end
