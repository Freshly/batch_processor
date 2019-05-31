# frozen_string_literal: true

# The job controller performs updates on and tracks details related to the jobs in a batch.
module BatchProcessor
  module Batch
    module JobController
      extend ActiveSupport::Concern

      included do
        define_callbacks_with_handler :job_enqueued, :job_retried
      end

      def job_enqueued
        raise BatchProcessor::BatchAlreadyEnqueuedError if enqueued?
        raise BatchProcessor::BatchNotProcessingError unless processing?

        run_callbacks(:job_enqueued) { details.increment(:enqueued_jobs_count) }
      end

      def job_retried
        raise BatchProcessor::BatchNotProcessingError unless processing?

        run_callbacks(:job_retried) { details.increment(:retried_jobs_count) }
      end
    end
  end
end
