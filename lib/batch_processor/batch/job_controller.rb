# frozen_string_literal: true

# The job controller performs updates on and tracks details related to the jobs in a batch.
module BatchProcessor
  module Batch
    module JobController
      extend ActiveSupport::Concern

      included do
        define_callbacks_with_handler :job_enqueued, :job_retried, :job_canceled
      end

      def job_enqueued
        raise BatchProcessor::BatchAlreadyEnqueuedError if enqueued?
        raise BatchProcessor::BatchNotProcessingError unless processing?

        run_callbacks(__method__) { details.increment(:enqueued_jobs_count) }
      end

      def job_retried
        raise BatchProcessor::BatchNotProcessingError unless processing?

        run_callbacks(__method__) do
          details.pipelined do
            details.increment(:total_retries_count)
            details.increment(:pending_jobs_count)
            details.decrement(:running_jobs_count)
          end
        end
      end

      def job_canceled
        raise BatchProcessor::BatchNotProcessingError unless processing?

        run_callbacks(__method__) do
          details.pipelined do
            details.increment(:canceled_jobs_count)
            details.decrement(:pending_jobs_count)
          end
        end
      end
    end
  end
end
