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

        def persisted?
          redis_hash.present?
        end

        def []=(field, value)
          redis.hset(redis_key, field, value)
          @redis_hash[field.to_s] = value
        end

        def merge(*args)
          hash = args.extract_options!.merge(args.first.try(:to_h) || {})
          redis.pipelined { hash.each { |key, value| self[key] = value } }
        end

        def reload_redis_hash
          @redis_hash = redis.hgetall(redis_key)
          self
        end
        alias_method :reload, :reload_redis_hash

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
