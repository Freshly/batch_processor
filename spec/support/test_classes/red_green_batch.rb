# frozen_string_literal: true

class RedGreenBatch < InheritedEmptyBatch
  with_parallel_processor

  class Collection < BatchCollection
    argument :color, allow_nil: false
    option :collection_size, default: 3

    validates :color, inclusion: { in: %w[red green] }

    def items
      Array.new(collection_size) { color }
    end
  end
end
