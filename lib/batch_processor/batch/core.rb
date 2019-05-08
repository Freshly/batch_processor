# frozen_string_literal: true

# Operations take a state as input.
module BatchProcessor
  module Batch
    module Core
      extend ActiveSupport::Concern

      included do
        attr_reader :input
      end

      def initialize(**input)
        run_callbacks(:initialize) { @input = input }
      end
    end
  end
end
