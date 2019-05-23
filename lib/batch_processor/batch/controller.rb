# frozen_string_literal: true

# The controller performs updates on and tracks details of a batch.
module BatchProcessor
  module Batch
    module Controller
      extend ActiveSupport::Concern

      def start
        raise BatchProcessor::BatchAlreadyStartedError if started?

        # TODO: Start the batch
      end
    end
  end
end
