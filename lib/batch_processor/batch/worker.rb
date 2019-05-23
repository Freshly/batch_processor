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
          raise ArgumentError, "worker must define .perform_now and .perform_later" unless valid_worker?(worker_class)

          @worker_class = worker_class
        end

        def valid_worker?(worker_class)
          worker_class.respond_to?(:perform_now) && worker_class.respond_to?(:perform_later)
        end

        def worker_class
          return @worker_class if defined?(@worker_class)

          "#{name.chomp("Batch")}Job".constantize
        end
      end
    end
  end
end
