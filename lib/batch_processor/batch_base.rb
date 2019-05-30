# frozen_string_literal: true

require_relative "batch/collection"
require_relative "batch/job"
require_relative "batch/processor"
require_relative "batch/predicates"
require_relative "batch/controller"

module BatchProcessor
  class BatchBase < Spicerack::InputModel
    option(:batch_id) { SecureRandom.urlsafe_base64(10) }

    def details
      BatchProcessor::BatchDetails.new(batch_id)
    end
    memoize :details

    include BatchProcessor::Batch::Collection
    include BatchProcessor::Batch::Job
    include BatchProcessor::Batch::Processor
    include BatchProcessor::Batch::Predicates
    include BatchProcessor::Batch::Controller
  end
end
