# frozen_string_literal: true

require_relative "batch/callbacks"
require_relative "batch/core"
require_relative "batch/collection"
require_relative "batch/worker"

module BatchProcessor
  class BatchBase < Instructor::Base
    include BatchProcessor::Batch::Callbacks
    include BatchProcessor::Batch::Core
    include BatchProcessor::Batch::Collection
    include BatchProcessor::Batch::Worker
  end
end
