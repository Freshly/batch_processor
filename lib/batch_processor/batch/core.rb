# frozen_string_literal: true

# Batches accept a unique identifier and input representing the arguments and options which define it's collection.
module BatchProcessor
  module Batch
    module Core
      extend ActiveSupport::Concern

      included do
        option(:batch_id) { SecureRandom.urlsafe_base64(10) }

        delegate :items, :item_to_job_params, to: :collection, prefix: true

        private

        attr_reader :collection_input
        memoize :collection
        memoize :collection_items
        memoize :details
      end

      def initialize(**input)
        super(input.slice(*_attributes))
        @collection_input = input.except(*_attributes)
      end

      def collection
        self.class::Collection.new(**collection_input)
      end

      def details
        BatchProcessor::BatchDetails.new(batch_id)
      end

      class_methods do
        def find(batch_id)
          class_name = BatchProcessor::BatchDetails.class_name_for_batch_id(batch_id)
          raise BatchProcessor::NotFoundError, "A Batch with id #{batch_id} was not found." if class_name.nil?

          batch_class = class_name.safe_constantize
          raise BatchProcessor::ClassMissingError, "#{class_name} is not a class" if batch_class.nil?

          batch_class.new(batch_id: batch_id)
        end

        private

        def define_callbacks_for(*events, type)
          callbacks = events.map { |event| "#{type}_#{event}".to_sym }
          define_callbacks_with_handler(*callbacks)
          callbacks
        end
      end
    end
  end
end
