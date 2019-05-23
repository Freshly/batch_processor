# frozen_string_literal: true

# A processor accepts a batch for processing.
module BatchProcessor
  module Processor
    module Core
      extend ActiveSupport::Concern

      included do
        attr_reader :batch
      end

      def initialize(batch)
        @batch = batch
      end
    end
  end
end
