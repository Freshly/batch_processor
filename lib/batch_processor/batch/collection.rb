# frozen_string_literal: true

# A batch defines a collection of data to process.
module BatchProcessor
  module Batch
    module Collection
      extend ActiveSupport::Concern

      included do
        memoize :collection
      end

      def collection
        build_collection
      end

      def build_collection
        []
      end

      def collection_item_to_job_params(item)
        item
      end
    end
  end
end
