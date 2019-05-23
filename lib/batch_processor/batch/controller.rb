# frozen_string_literal: true

# The controller performs updates on and tracks details of a batch.
module BatchProcessor
  module Batch
    module Controller
      extend ActiveSupport::Concern

      included do
        delegate :allow_empty?, to: :class
        delegate :pipelined, to: :details
      end

      class_methods do
        def allow_empty
          @allow_empty = true
        end

        def allow_empty?
          @allow_empty.present?
        end
      end

      def start
        raise BatchProcessor::BatchAlreadyStartedError if started?
        raise BatchProcessor::BatchEmptyError if collection.empty? && !allow_empty?

        run_callbacks(:batch_started) do
          pipelined do
            details.started_at = Time.current
            details.size = collection.size
          end
        end

        started?
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
