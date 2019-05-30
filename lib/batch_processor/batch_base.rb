# frozen_string_literal: true

require_relative "batch/callbacks"
require_relative "batch/core"
require_relative "batch/collection"
require_relative "batch/job"
require_relative "batch/processor"
require_relative "batch/predicates"
require_relative "batch/controller"

module BatchProcessor
  class BatchBase < Spicerack::InputModel
    include BatchProcessor::Batch::Callbacks
    include BatchProcessor::Batch::Core
    include BatchProcessor::Batch::Collection
    include BatchProcessor::Batch::Job
    include BatchProcessor::Batch::Processor
    include BatchProcessor::Batch::Predicates
    include BatchProcessor::Batch::Controller
  end
end
