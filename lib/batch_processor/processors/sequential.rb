# frozen_string_literal: true

# The Sequential Processor uses `.perform_now` to procedurally process each job within the current thread.
module BatchProcessor
  module Processors
    class Sequential < BatchProcessor::ProcessorBase
      option :continue_after_exception, default: false
      option :sorted, default: false

      class << self
        def disable_retries?
          true
        end
      end

      def process_collection_item(item)
        job = batch.job_class.new(item)
        job.batch_id = batch.batch_id
        job.perform_now
      rescue StandardError => exception
        raise exception unless continue_after_exception
      end

      private

      def iterator_method
        sorted ? :each : super
      end
    end
  end
end
