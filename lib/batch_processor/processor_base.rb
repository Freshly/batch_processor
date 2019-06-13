# frozen_string_literal: true

require_relative "processor/process"
require_relative "processor/execute"

module BatchProcessor
  class ProcessorBase < Spicerack::InputObject
    argument :batch, allow_nil: false

    class << self
      def disable_retries?
        false
      end
    end

    include BatchProcessor::Processor::Process
    include BatchProcessor::Processor::Execute
  end
end
