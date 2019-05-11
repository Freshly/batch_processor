# frozen_string_literal: true

# Batch Details are persisted in a Redis hash.
module BatchProcessor
  module Batch
    module Details
      module RedisHash
        extend ActiveSupport::Concern

        included do
          delegate :name, to: :class, prefix: true

          memoize :redis
          memoize :redis_key

          set_callback(:initialize, :after) { reload_redis_hash }

          attr_reader :redis_hash
        end

        def reload_redis_hash
          @redis_hash = redis.hgetall(redis_key)
        end

        def redis_key
          "BatchProcessor:#{batch_id}"
        end

        def redis
          Redis.new
        end
      end
    end
  end
end
