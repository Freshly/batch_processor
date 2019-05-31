# frozen_string_literal: true

# The job controller performs updates on and tracks details related to the jobs in a batch.
module BatchProcessor
  module Batch
    module JobController
      extend ActiveSupport::Concern

      included do
        # define_callbacks_with_handler :batch_started, :batch_finished
      end
    end
  end
end
