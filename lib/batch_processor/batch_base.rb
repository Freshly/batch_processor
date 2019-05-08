# frozen_string_literal: true

require_relative "batch/callbacks"
require_relative "batch/core"

module BatchProcessor
  class BatchBase
    include Technologic
    include BatchProcessor::Batch::Callbacks
    include BatchProcessor::Batch::Core
  end
end
