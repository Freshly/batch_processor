# frozen_string_literal: true

module BatchProcessor
  module Batch
    module Malfunction
      extend ActiveSupport::Concern

      included do
        attr_reader :malfunction
      end

      private

      def build_malfunction(malfunction_class, context = nil)
        @malfunction = malfunction_class.build(context)
      end
    end
  end
end
