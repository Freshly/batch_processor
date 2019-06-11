# frozen_string_literal: true

module BatchProcessor
  module Processors
    class Parallel < BatchProcessor::ProcessorBase
      set_callback(:collection_processed, :after) { batch.enqueued }

      def process_collection_item(item)
        batch.job_class.perform_later(item)
      end
    end
  end
end
