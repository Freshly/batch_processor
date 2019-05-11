# frozen_string_literal: true

# A batch defines a collection of data to process.
module BatchProcessor
  module Batch
    module Uniqueness
      extend ActiveSupport::Concern

      included do
        memoize :details
        set_callback(:initialize, :after) { raise BatchProcessor::ExistingBatchError if details.persisted? }
      end

      def details
        BatchProcessor::BatchDetails.new(id)
      end
    end
  end
end
