# frozen_string_literal: true

# Processing a batch performs a job for each item in the batch collection.
module BatchProcessor
  module Processor
    module Process
      extend ActiveSupport::Concern

      def process
        batch.start

        # TODO: Process the collections

        batch.finish unless batch.unfinished_jobs?
      end
    end
  end
end
