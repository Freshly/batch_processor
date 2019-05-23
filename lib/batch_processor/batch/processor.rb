# frozen_string_literal: true

# When processed, the batch performs a job for each item in its collection.
module BatchProcessor
  module Batch
    module Processor
      extend ActiveSupport::Concern

      PROCESSOR_CLASS_BY_STRATEGY = {
        default: BatchProcessor::ProcessorBase,
        parallel: BatchProcessor::ProcessorBase,
        sequential: BatchProcessor::ProcessorBase,
      }.freeze

      included do
        delegate :processor_class, to: :class
      end

      class_methods do
        PROCESSOR_CLASS_BY_STRATEGY.except(:default).each do |strategy, processor_class|
          strategy_method = "with_#{strategy}_processor".to_sym
          define_method(strategy_method) { @processor_class = processor_class }
          private strategy_method
        end

        private

        def processor_class
          return @processor_class if defined?(@processor_class)

          PROCESSOR_CLASS_BY_STRATEGY[:default]
        end
      end

      def process
        processor_class.execute(self)
      end
    end
  end
end
