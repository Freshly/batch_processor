# frozen_string_literal: true

require_relative "processor/callbacks"
require_relative "processor/core"

module BatchProcessor
  class ProcessorBase
    include BatchProcessor::Processor::Callbacks
    include BatchProcessor::Processor::Core
  end
end
