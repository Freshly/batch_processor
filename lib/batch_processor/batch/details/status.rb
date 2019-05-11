# frozen_string_literal: true

# The batch detail's status describes the milestones in a batch lifecycle.
module BatchProcessor
  module Batch
    module Details
      module Status
        extend ActiveSupport::Concern

        def started?
          false
        end

        def finished?
          false
        end
      end
    end
  end
end
