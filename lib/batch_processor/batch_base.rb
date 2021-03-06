# frozen_string_literal: true

require_relative "batch/core"
require_relative "batch/job"
require_relative "batch/malfunction"
require_relative "batch/processor"
require_relative "batch/predicates"
require_relative "batch/controller"
require_relative "batch/job_controller"

# A **Batch** defines, controls, and monitors the processing of a collection of items with an `ActiveJob`.
module BatchProcessor
  class BatchBase < Spicerack::InputObject
    class BatchCollection < BatchProcessor::Collection; end
    class Collection < BatchCollection; end

    include Conjunction::Junction
    suffixed_with "Batch"

    include BatchProcessor::Batch::Core
    include BatchProcessor::Batch::Job
    include BatchProcessor::Batch::Malfunction
    include BatchProcessor::Batch::Processor
    include BatchProcessor::Batch::Predicates
    include BatchProcessor::Batch::Controller
    include BatchProcessor::Batch::JobController
  end
end
