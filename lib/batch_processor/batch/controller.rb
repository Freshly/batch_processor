# frozen_string_literal: true

# The controller performs updates on and tracks details of a batch.
module BatchProcessor
  module Batch
    module Controller
      extend ActiveSupport::Concern

      included do
        batch_callbacks :started, :enqueued, :aborted, :cleared, :finished

        delegate :allow_empty?, to: :class
        delegate :name, to: :class, prefix: true
        delegate :pipelined, to: :details
      end

      class_methods do
        def inherited(base)
          base.allow_empty if allow_empty?
          super
        end

        def allow_empty?
          @allow_empty.present?
        end

        protected

        def allow_empty
          @allow_empty = true
        end

        private

        def batch_callbacks(*events)
          define_callbacks_for(*events, :batch).each do |batch_event|
            set_callback batch_event, :around, ->(_, block) { surveil(batch_event, batch_id: batch_id) { block.call } }
          end
        end
      end

      def start
        raise BatchProcessor::CollectionInvalidError unless collection.valid?
        raise BatchProcessor::AlreadyStartedError if started?
        raise BatchProcessor::CollectionEmptyError if collection_items.empty? && !allow_empty?

        run_callbacks(:batch_started) do
          collection_size = collection_items.count

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
        raise BatchProcessor::AlreadyEnqueuedError if enqueued?
        raise BatchProcessor::NotStartedError unless started?

        run_callbacks(:batch_enqueued) { details.enqueued_at = Time.current }

        enqueued?
      end

      def abort!
        raise BatchProcessor::NotStartedError unless started?
        raise BatchProcessor::AlreadyFinishedError if finished?
        raise BatchProcessor::AlreadyAbortedError if aborted?

        run_callbacks(:batch_aborted) { details.aborted_at = Time.current }

        aborted?
      end

      def clear!
        raise BatchProcessor::NotAbortedError unless aborted?
        raise BatchProcessor::AlreadyFinishedError if finished?
        raise BatchProcessor::AlreadyClearedError if cleared?

        run_callbacks(:batch_cleared) do
          pending_jobs_count = details.pending_jobs_count
          running_jobs_count = details.running_jobs_count

          pipelined do
            details.cleared_at = Time.current
            details.finished_at = Time.current
            details.decrement(:pending_jobs_count, by: pending_jobs_count)
            details.decrement(:running_jobs_count, by: running_jobs_count)
            details.increment(:cleared_jobs_count, by: pending_jobs_count + running_jobs_count)
          end
        end

        run_callbacks(:batch_finished)

        cleared?
      end

      def finish
        raise BatchProcessor::AlreadyFinishedError if finished?
        raise BatchProcessor::StillProcessingError if unfinished_jobs?

        run_callbacks(:batch_finished) { details.finished_at = Time.current }

        finished?
      end
    end
  end
end
