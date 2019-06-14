# frozen_string_literal: true

module BatchProcessor
  module Processors
    class Parallel < BatchProcessor::ProcessorBase
      set_callback(:collection_processed, :after) { batch.enqueued }

      def process_collection_item(item)
        job = batch.job_class.new(item)
        job.batch_id = batch.batch_id
        job.enqueue
      end
    end
  end
end
