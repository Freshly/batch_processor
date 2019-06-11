# frozen_string_literal: true

module BatchProcessor
  module Processors
    class Sequential < BatchProcessor::ProcessorBase
      option :continue_after_exception, default: false
      option :sorted, default: false

      def process_collection_item(item)
        batch.job_class.perform_now(item)
      rescue StandardError => exception
        raise exception unless continue_after_exception
      end

      private

      def iterator_method
        sorted ? :each : super
      end
    end
  end
end
