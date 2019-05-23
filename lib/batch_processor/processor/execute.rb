# frozen_string_literal: true

# When executed, the processor performs a job for each item in the batch collection.
module BatchProcessor
  module Processor
    module Execute
      extend ActiveSupport::Concern

      included do
        set_callback :execute, :around, ->(_, block) { surveil(:execute) { block.call } }
      end

      def execute
        raise BatchProcessor::BatchEmptyError if batch.collection.empty?

        run_callbacks(:execute) { true }
      end
    end
  end
end
