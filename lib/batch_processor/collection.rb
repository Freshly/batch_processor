# frozen_string_literal: true

# A `Collection` takes input to validate and build a (possibly ordered) list of items to process with the Batch's job.
module BatchProcessor
  class Collection < Spicerack::InputModel
    def items
      []
    end

    def item_to_job_params(item)
      item
    end
  end
end
