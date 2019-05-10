# frozen_string_literal: true

# A batch accepts input which may be used to generate the collection of data process.
module BatchProcessor
  module Batch
    module Core
      extend ActiveSupport::Concern

      included do
        attr_reader :id, :input
      end

      def initialize(id = nil, **input)
        run_callbacks(:initialize) do
          @id = id
          @input = input
        end
      end
    end
  end
end
