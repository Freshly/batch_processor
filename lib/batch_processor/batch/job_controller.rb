# frozen_string_literal: true

# The job controller performs updates on and tracks details related to the jobs in a batch.
module BatchProcessor
  module Batch
    module JobController
      extend ActiveSupport::Concern

      class_methods do
        private

        def job_callbacks(*events)
          job_events = events.map { |event| "job_#{event}".to_sym }

          define_callbacks_with_handler(*job_events)

          job_events.each do |job_event|
            set_callback job_event, :around, ->(_, block) { surveil(job_event) { block.call } }
          end
        end
      end

      included do
        job_callbacks :enqueued, :running, :retried, :canceled, :success, :failure

        on_job_success :finish, unless: :unfinished_jobs?
        on_job_failure :finish, unless: :unfinished_jobs?
        on_job_canceled :finish, unless: :unfinished_jobs?
      end

      def job_enqueued
        raise BatchProcessor::AlreadyEnqueuedError if enqueued?
        raise BatchProcessor::NotProcessingError unless processing?

        run_callbacks(__method__) { details.increment(:enqueued_jobs_count) }
      end

      def job_running
        raise BatchProcessor::NotProcessingError unless processing?

        run_callbacks(__method__) do
          details.pipelined do
            details.increment(:running_jobs_count)
            details.decrement(:pending_jobs_count)
          end
        end
      end

      def job_retried
        raise BatchProcessor::NotProcessingError unless processing?

        run_callbacks(__method__) do
          details.pipelined do
            details.increment(:total_retries_count)
            details.increment(:pending_jobs_count)
            details.decrement(:failed_jobs_count)
          end
        end
      end

      def job_success
        raise BatchProcessor::NotStartedError unless started?
        raise BatchProcessor::AlreadyFinishedError if finished?

        run_callbacks(__method__) do
          details.pipelined do
            details.increment(:successful_jobs_count)
            details.decrement(:running_jobs_count)
          end
        end
      end

      def job_failure
        raise BatchProcessor::NotStartedError unless started?
        raise BatchProcessor::AlreadyFinishedError if finished?

        run_callbacks(__method__) do
          details.pipelined do
            details.increment(:failed_jobs_count)
            details.decrement(:running_jobs_count)
          end
        end
      end

      def job_canceled
        raise BatchProcessor::NotAbortedError unless aborted?

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
