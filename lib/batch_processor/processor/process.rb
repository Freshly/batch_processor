# frozen_string_literal: true

# Processing a batch performs a job for each item in the batch collection.
module BatchProcessor
  module Processor
    module Process
      extend ActiveSupport::Concern

      included do
        define_callbacks :process_item
        set_callback :process_item, :around, ->(_, block) { surveil(:process_item) { block.call } }
      end

      def process
        batch.start

        process_collection

        batch.finish unless batch.unfinished_jobs?
      end

      def process_collection_item(_item)
        # Abstract
      end

      private

      def process_collection
        batch.collection.public_send(batch.collection.respond_to?(:find_each) ? :find_each : :each) do |item|
          run_callbacks(:process_item) { process_collection_item(item) }
        end
      end
    end
  end
end
