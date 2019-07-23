# frozen_string_literal: true

require_relative "processor/process"
require_relative "processor/execute"

# A **Processor** is a service object which determines how to perform a Batch's jobs to properly process its collection.
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
