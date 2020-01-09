# frozen_string_literal: true

# Unless otherwise specified a `Batch` uses the **default** `Parallel` Processor.
module BatchProcessor
  module Batch
    module Processor
      extend ActiveSupport::Concern

      # The default processors can be redefined and new custom ones can be added as well.
      # rubocop:disable Style/MutableConstant
      PROCESSOR_CLASS_BY_STRATEGY = {
        default: BatchProcessor::Processors::Parallel,
        parallel: BatchProcessor::Processors::Parallel,
        sequential: BatchProcessor::Processors::Sequential,
      }
      # rubocop:enable Style/MutableConstant

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

        def process(*arguments)
          new(*arguments).process
        end

        def process!(*arguments)
          new(*arguments).process!
        end

        def processor_class
          return @processor_class if defined?(@processor_class)

          PROCESSOR_CLASS_BY_STRATEGY[:default]
        end

        def inherited(base)
          dup = _processor_options.dup
          base._processor_options = dup.each { |k, v| dup[k] = v.dup }
          super
        end

        private

        # Certain processors have configurable options; this configuration is specified in the Batch's definition.
        def processor_option(option, value = nil)
          _processor_options[option.to_sym] = value
        end
      end

      def process!
        processor_class.execute(batch: self, **_processor_options)
        self
      end

      def process
        process!
      rescue BatchProcessor::Error => exception
        handle_exception(exception)
        self
      end

      private

      def handle_exception(exception)
        malfunction_class = exception.try(:conjugate, BatchProcessor::Malfunction::Base)
        error :process_error, exception: exception and return if malfunction_class.nil?

        if malfunction_class <= BatchProcessor::Malfunction::CollectionInvalid
          build_malfunction malfunction_class, collection
        else
          build_malfunction malfunction_class
        end
      end
    end
  end
end
