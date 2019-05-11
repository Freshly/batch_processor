# frozen_string_literal: true

# A batch defines a collection of data to process.
module BatchProcessor
  module Batch
    module Details
      extend ActiveSupport::Concern

      included do
        memoize :details
      end

      def details
        BatchProcessor::BatchDetails.new(id)
      end
    end
  end
end
