# frozen_string_literal: true

require_relative "batch/callbacks"
require_relative "batch/core"
require_relative "batch/collection"
require_relative "batch/details"

module BatchProcessor
  class BatchBase
    include ShortCircuIt
    include Technologic
    include BatchProcessor::Batch::Callbacks
    include BatchProcessor::Batch::Core
    include BatchProcessor::Batch::Collection
    include BatchProcessor::Batch::Details
  end
end
