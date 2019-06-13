# frozen_string_literal: true

require_relative "batch/job"
require_relative "batch/processor"
require_relative "batch/predicates"
require_relative "batch/controller"
require_relative "batch/job_controller"

module BatchProcessor
  class BatchBase < Spicerack::InputObject
    option(:batch_id) { SecureRandom.urlsafe_base64(10) }

    class Collection < BatchProcessor::Collection; end

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

    delegate :item_to_job_params, to: :batch_collection

    def collection
      self.class::Collection.new(**input.except(:batch_id))
    end
    memoize :collection

    def details
      BatchProcessor::BatchDetails.new(batch_id)
    end
    memoize :details
  end
end
