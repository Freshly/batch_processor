# frozen_string_literal: true

# Processing a batch performs a job for each item in the batch collection.
module BatchProcessor
  module Processor
    module Process
      extend ActiveSupport::Concern

      included do
        define_callbacks :collection_processed, :item_processed
        set_callback :collection_processed, :around, ->(_, block) { surveil(:collection_processed) { block.call } }
        set_callback :item_processed, :around, ->(_, block) { surveil(:item_processed) { block.call } }
      end

      def process
        batch.start

        run_callbacks(:collection_processed) { process_collection }

        batch.finish unless batch.unfinished_jobs?
      end

      def process_collection_item(_item)
        # Abstract
      end

      private

      def process_collection
        batch.collection.public_send(batch.collection.respond_to?(:find_each) ? :find_each : :each) do |item|
          run_callbacks(:item_processed) { process_collection_item(item) }
        end
      end
    end
  end
end
