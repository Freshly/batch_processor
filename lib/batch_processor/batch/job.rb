# frozen_string_literal: true

# A batch job is what process each item in the collection.
module BatchProcessor
  module Batch
    module Job
      extend ActiveSupport::Concern

      included do
        delegate :job_class, to: :class
      end

      class_methods do
        private

        def process_with_job(job_class)
          raise ArgumentError, "Unbatchable job" unless job_class.ancestors.include? BatchProcessor::BatchJob

          @job_class = job_class
        end

        def job_class
          return @job_class if defined?(@job_class)

          "#{name.chomp("Batch")}Job".constantize
        end
      end
    end
  end
end
