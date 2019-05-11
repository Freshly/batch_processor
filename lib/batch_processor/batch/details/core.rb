# frozen_string_literal: true

# A batch details the results of jobs it has processed and keeps an overall summary status.
module BatchProcessor
  module Batch
    module Details
      module Core
        extend ActiveSupport::Concern

        included do
          attr_reader :batch_id
        end

        def initialize(batch_id)
          run_callbacks(:initialize) { @batch_id = batch_id }
        end
      end
    end
  end
end
