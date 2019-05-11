# frozen_string_literal: true

# A batch ID must be unique across all known batches.
module BatchProcessor
  module Batch
    module Uniqueness
      extend ActiveSupport::Concern

      included do
        set_callback(:initialize, :after) do
          raise BatchProcessor::ExistingBatchError if details.persisted? && input.present?
        end
      end
    end
  end
end
