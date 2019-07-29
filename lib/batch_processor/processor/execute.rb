# frozen_string_literal: true

# When `.process` is called on a Batch, `.execute` is called on the `Processor` specified in the Batch's definition.
module BatchProcessor
  module Processor
    module Execute
      extend ActiveSupport::Concern

      included do
        define_callbacks :execute
        set_callback :execute, :around, ->(_, block) { surveil(:execute) { block.call } }
      end

      class_methods do
        def execute(*arguments)
          new(*arguments).execute
        end
      end

      def execute
        run_callbacks(:execute) { process }
      end
    end
  end
end
