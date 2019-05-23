# frozen_string_literal: true

# Processing a batch performs a job for each item in the batch collection.
module BatchProcessor
  module Processor
    module Process
      extend ActiveSupport::Concern

      def process
        # TODO: batch.started?
        raise BatchProcessor::BatchAlreadyStartedError if batch.details.started_at?

        # TODO: batch.start

        # TODO: Actually process the batch
      end
    end
  end
end
