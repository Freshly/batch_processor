# frozen_string_literal: true

# The Parallel Processor enqueues jobs to be performed later.
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
