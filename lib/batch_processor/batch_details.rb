# frozen_string_literal: true

# The **Details** of a batch are the times of critical lifecycle events and the summary counts of processed jobs.
module BatchProcessor
  class BatchDetails < Spicerack::RedisModel
    attr_reader :batch_id

    field :class_name, :string

    field :started_at, :datetime
    field :enqueued_at, :datetime
    field :aborted_at, :datetime
    field :cleared_at, :datetime
    field :finished_at, :datetime

    field :size, :integer, default: 0

    field :enqueued_jobs_count, :integer, default: 0

    field :pending_jobs_count, :integer, default: 0
    field :running_jobs_count, :integer, default: 0

    field :successful_jobs_count, :integer, default: 0
    field :failed_jobs_count, :integer, default: 0

    field :canceled_jobs_count, :integer, default: 0
    field :cleared_jobs_count, :integer, default: 0

    field :total_retries_count, :integer, default: 0

    class << self
      def redis_key_for_batch_id(batch_id)
        "#{name}::#{batch_id}"
      end

      def class_name_for_batch_id(batch_id)
        default_redis.hget(redis_key_for_batch_id(batch_id), "class_name")
      end
    end

    def initialize(batch_id)
      @batch_id = batch_id
      super redis_key: self.class.redis_key_for_batch_id(batch_id)
    end

    def unfinished_jobs_count
      sum_up(:pending_jobs_count, :running_jobs_count)
    end

    def finished_jobs_count
      sum_up(:successful_jobs_count, :failed_jobs_count, :canceled_jobs_count)
    end

    def total_jobs_count
      sum_up(
        :pending_jobs_count,
        :running_jobs_count,
        :successful_jobs_count,
        :failed_jobs_count,
        :canceled_jobs_count,
        :cleared_jobs_count,
      )
    end

    private

    def sum_up(*fields)
      values_at(*fields).map(&:to_i).sum
    end
  end
end
