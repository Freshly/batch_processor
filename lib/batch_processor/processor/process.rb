# frozen_string_literal: true

# Processing a batch performs a job for each item in the batch collection.
module BatchProcessor
  module Processor
    module Process
      extend ActiveSupport::Concern

      def process
        raise BatchProcessor::BatchAlreadyStartedError if batch.started?

        # TODO: batch.start

        # TODO: Actually process the batch
      end
    end
  end
end
