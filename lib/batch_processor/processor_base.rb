# frozen_string_literal: true

require_relative "processor/callbacks"
require_relative "processor/core"
require_relative "processor/options"
require_relative "processor/process"
require_relative "processor/execute"

module BatchProcessor
  class ProcessorBase
    include Technologic
    include BatchProcessor::Processor::Callbacks
    include BatchProcessor::Processor::Core
    include BatchProcessor::Processor::Options
    include BatchProcessor::Processor::Process
    include BatchProcessor::Processor::Execute
  end
end
