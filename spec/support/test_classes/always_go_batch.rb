# frozen_string_literal: true

class AlwaysGoBatch < BatchProcessor::BatchBase
  with_sequential_processor
  processor_option :continue_after_exception, true
  process_with_job StopOrGoJob

  class Collection < BatchCollection
    def items
      %w[green yellow red]
    end
  end
end
