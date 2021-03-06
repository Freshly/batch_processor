# frozen_string_literal: true

# Processing a Batch performs a job for each item in its collection if **and only if** it has a valid collection.
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

        batch.finish unless batch.finished? || batch.unfinished_jobs?

        self
      end

      def process_collection_item(_item)
        # Abstract
      end

      private

      def iterator_method
        batch.collection_items.respond_to?(:find_each) ? :find_each : :each
      end

      def process_collection
        batch.collection_items.public_send(iterator_method) do |item|
          run_callbacks(:item_processed) { process_collection_item(batch.collection_item_to_job_params(item)) }
        end
      end
    end
  end
end
