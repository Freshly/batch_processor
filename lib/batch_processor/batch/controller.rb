# frozen_string_literal: true

# The controller performs updates on and tracks details of a batch.
module BatchProcessor
  module Batch
    module Controller
      extend ActiveSupport::Concern

      included do
        delegate :pipelined, to: :details
      end

      def start
        raise BatchProcessor::BatchAlreadyStartedError if started?

        pipelined do
          details.started_at = Time.current
          details.size = collection.size
        end
      end
    end
  end
end