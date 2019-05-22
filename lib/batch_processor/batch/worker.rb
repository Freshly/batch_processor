# frozen_string_literal: true

# A batch worker is what process each item in the collection.
module BatchProcessor
  module Batch
    module Worker
      extend ActiveSupport::Concern

      included do
        delegate :worker_class, to: :class
      end

      class_methods do
        private

        def process_with(worker_class)
          raise TypeError, "worker_class must be a Class" unless worker_class.is_a?(Class)
          raise ArgumentError, "worker_class must define .perform_now" unless worker_class.respond_to?(:perform_now)
          raise ArgumentError, "worker_class must define .perform_later" unless worker_class.respond_to?(:perform_later)

          @worker_class = worker_class
        end

        def worker_class
          return @worker_class if defined?(@worker_class)

          "#{name.chomp("Batch")}Job".constantize
        end
      end
    end
  end
end
