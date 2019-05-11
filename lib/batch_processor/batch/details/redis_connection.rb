# frozen_string_literal: true

# Batch Details are persisted in Redis for parallel processing.
module BatchProcessor
  module Batch
    module Details
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
end
