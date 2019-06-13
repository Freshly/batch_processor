# frozen_string_literal: true

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
