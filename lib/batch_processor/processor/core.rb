# frozen_string_literal: true

# A processor accepts a batch for processing.
module BatchProcessor
  module Processor
    module Core
      extend ActiveSupport::Concern

      included do
        attr_reader :batch, :options
      end

      def initialize(batch, **options)
        @batch = batch
        @options = options
      end
    end
  end
end
