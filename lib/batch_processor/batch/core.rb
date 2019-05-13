# frozen_string_literal: true

# A batch accepts input which may be used to generate the collection of data process.
module BatchProcessor
  module Batch
    module Core
      extend ActiveSupport::Concern

      included do
        attr_reader :id, :details
      end

      def initialize(id = nil, **input)
        @id = id || SecureRandom.urlsafe_base64(10)
        @details = BatchProcessor::BatchDetails.new(@id)

        raise BatchProcessor::ExistingBatchError if details.persisted? && input.present?

        super(**input)
      end
    end
  end
end
