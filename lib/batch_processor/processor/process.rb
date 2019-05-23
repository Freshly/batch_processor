# frozen_string_literal: true

# Processing a batch performs a job for each item in the batch collection.
module BatchProcessor
  module Processor
    module Process
      extend ActiveSupport::Concern

      def process
        raise BatchProcessor::BatchAlreadyStartedError if batch.started?

        batch.start
      end
    end
  end
end
