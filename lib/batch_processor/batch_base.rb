# frozen_string_literal: true

require_relative "batch/collection"
require_relative "batch/job"
require_relative "batch/processor"
require_relative "batch/predicates"
require_relative "batch/controller"
require_relative "batch/job_controller"

module BatchProcessor
  class BatchBase < Spicerack::InputModel
    option(:batch_id) { SecureRandom.urlsafe_base64(10) }

    include BatchProcessor::Batch::Collection
    include BatchProcessor::Batch::Job
    include BatchProcessor::Batch::Processor
    include BatchProcessor::Batch::Predicates
    include BatchProcessor::Batch::Controller
    include BatchProcessor::Batch::JobController

    class << self
      def find(batch_id)
        class_name = BatchProcessor::BatchDetails.class_name_for_batch_id(batch_id)
        raise BatchProcessor::BatchNotFound, "A Batch with id #{batch_id} was not found." if class_name.nil?

        batch_class = class_name.safe_constantize
        raise BatchProcessor::BatchClassMissing, "#{class_name} is not a class" if batch_class.nil?

        batch_class.new(batch_id: batch_id)
      end
    end

    def details
      BatchProcessor::BatchDetails.new(batch_id)
    end
    memoize :details
  end
end
