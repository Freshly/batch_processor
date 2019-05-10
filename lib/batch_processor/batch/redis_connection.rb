# frozen_string_literal: true

# A batch uses Redis to track its state of when parallel processing.
module BatchProcessor
  module Batch
    module RedisConnection
      extend ActiveSupport::Concern

      included do
        memoize :redis
      end

      private

      def redis
        Redis.new
      end
    end
  end
end
