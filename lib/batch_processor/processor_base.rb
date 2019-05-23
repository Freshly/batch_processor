# frozen_string_literal: true

require_relative "processor/callbacks"
require_relative "processor/core"
require_relative "processor/execute"

module BatchProcessor
  class ProcessorBase
    include Technologic
    include BatchProcessor::Processor::Callbacks
    include BatchProcessor::Processor::Core
    include BatchProcessor::Processor::Execute
  end
end
