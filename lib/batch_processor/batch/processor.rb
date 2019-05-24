# frozen_string_literal: true

# When processed, the batch performs a job for each item in its collection.
module BatchProcessor
  module Batch
    module Processor
      extend ActiveSupport::Concern

      PROCESSOR_CLASS_BY_STRATEGY = {
        default: BatchProcessor::Processors::Parallel,
        parallel: BatchProcessor::Processors::Parallel,
        sequential: BatchProcessor::Processors::Sequential,
      }.freeze

      included do
        class_attribute :_processor_options, instance_writer: false, default: {}
        delegate :processor_class, :processor_options, to: :class
      end

      class_methods do
        PROCESSOR_CLASS_BY_STRATEGY.except(:default).each do |strategy, processor_class|
          strategy_method = "with_#{strategy}_processor".to_sym
          define_method(strategy_method) { @processor_class = processor_class }
          private strategy_method
        end

        def inherited(base)
          dup = _processor_options.dup
          base._processor_options = dup.each { |k, v| dup[k] = v.dup }
          super
        end

        private

        def processor_class
          return @processor_class if defined?(@processor_class)

          PROCESSOR_CLASS_BY_STRATEGY[:default]
        end

        def processor_option(option, value = nil)
          _processor_options[option.to_sym] = value
        end
      end

      def process
        processor_class.execute(self, **_processor_options)
      end
    end
  end
end
