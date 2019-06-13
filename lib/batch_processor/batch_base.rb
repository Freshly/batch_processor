# frozen_string_literal: true

require_relative "batch/core"
require_relative "batch/job"
require_relative "batch/processor"
require_relative "batch/predicates"
require_relative "batch/controller"
require_relative "batch/job_controller"

module BatchProcessor
  class BatchBase < Spicerack::InputObject
    class BatchCollection < BatchProcessor::Collection; end
    class Collection < BatchCollection; end

    include BatchProcessor::Batch::Core
    include BatchProcessor::Batch::Job
    include BatchProcessor::Batch::Processor
    include BatchProcessor::Batch::Predicates
    include BatchProcessor::Batch::Controller
    include BatchProcessor::Batch::JobController
  end
end
