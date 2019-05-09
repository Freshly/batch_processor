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
        []
      end
    end
  end
end
