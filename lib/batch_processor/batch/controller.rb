# frozen_string_literal: true

# The controller performs updates on and tracks details of a batch.
module BatchProcessor
  module Batch
    module Controller
      extend ActiveSupport::Concern

      included do
        batch_callbacks :started, :enqueued, :aborted, :finished

        delegate :allow_empty?, to: :class
        delegate :name, to: :class, prefix: true
        delegate :pipelined, to: :details
      end

      class_methods do
        def allow_empty
          @allow_empty = true
        end

        def allow_empty?
          @allow_empty.present?
        end

        private

        def batch_callbacks(*events)
          batch_events = events.map { |event| "batch_#{event}".to_sym }

          define_callbacks_with_handler(*batch_events)

          batch_events.each do |batch_event|
            set_callback batch_event, :around, ->(_, block) { surveil(batch_event) { block.call } }
          end
        end
      end

      def start
        raise BatchProcessor::BatchAlreadyStartedError if started?
        raise BatchProcessor::BatchEmptyError if collection.empty? && !allow_empty?

        run_callbacks(:batch_started) do
          collection_size = collection.count

          pipelined do
            details.class_name = class_name
            details.started_at = Time.current
            details.size = collection_size
            details.pending_jobs_count = collection_size
          end
        end

        started?
      end

      def enqueued
        raise BatchProcessor::BatchAlreadyEnqueuedError if enqueued?
        raise BatchProcessor::BatchNotStartedError unless started?

        run_callbacks(:batch_enqueued) { details.enqueued_at = Time.current }

        enqueued?
      end

      def abort!
        raise BatchProcessor::BatchNotStartedError unless started?
        raise BatchProcessor::BatchAlreadyFinishedError if finished?
        raise BatchProcessor::BatchAlreadyAbortedError if aborted?

        run_callbacks(:batch_aborted) { details.aborted_at = Time.current }

        aborted?
      end

      def finish
        raise BatchProcessor::BatchAlreadyFinishedError if finished?
        raise BatchProcessor::BatchStillProcessingError if unfinished_jobs?

        run_callbacks(:batch_finished) { details.finished_at = Time.current }

        finished?
      end
    end
  end
end
