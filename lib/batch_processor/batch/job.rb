# frozen_string_literal: true

# Unless otherwise specified a `Batch` assumes its **Job** class shares a common name.
module BatchProcessor
  module Batch
    module Job
      extend ActiveSupport::Concern

      included do
        delegate :job_class, to: :class
      end

      class_methods do
        def job_class
          return @job_class if defined?(@job_class)

          "#{name.chomp("Batch")}Job".constantize
        end

        private

        def process_with_job(job_class)
          raise ArgumentError, "Unbatchable job" unless job_class.ancestors.include? BatchProcessor::BatchJob

          @job_class = job_class
        end
      end
    end
  end
end
