# frozen_string_literal: true

# Only a **BatchJob** can be used to perform work, but it can be run outside of a batch as well.
# Therefore, the recommendation is to make `ApplicationJob` inherit from `BatchJob`.
module BatchProcessor
  # BatchProcessor depends on ActiveJob for handling the processing of individual items in a collection.
  class BatchJob < ActiveJob::Base
    attr_accessor :batch_id, :tracked_batch_running, :tracked_batch_failure

    include Technologic

    class BatchAbortedError < StandardError; end

    after_enqueue(if: :batch_job?) do |job|
      if job.executions == 0
        batch.job_enqueued
      else
        batch.job_retried
      end
    end

    before_perform(if: :batch_job?) do
      raise BatchAbortedError if batch.aborted?

      self.tracked_batch_running = true

      batch.job_running
    end

    after_perform(if: :batch_job?) { batch.job_success }

    # Some combination of Sidekiq + ActiveJob + Postgres + Deadlocks = this getting called twice for the same instance.
    # It is unclear WHY that situation happens, but during the second execution, the instance no longer has it's job_id
    # but somehow still has a batch ID. It seems regardless, an internal semaphore seems to prevent miscounting in that
    # situation. I'd love to know what the root cause is behind it, but async debugging is time consuming and hard. :(
    def rescue_with_handler(exception)
      batch.job_canceled and return exception if exception.is_a?(BatchAbortedError)

      batch_job_failure(exception) if batch_job? && !tracked_batch_failure
      self.tracked_batch_failure = true

      super
    end

    def retry_job(*)
      return if batch_job? && batch.processor_class.disable_retries?

      super
    end

    def serialize
      super.merge("batch_id" => batch_id) # rubocop:disable Style/StringHashKeys
    end

    def deserialize(job_data)
      super(job_data)
      self.batch_id = job_data["batch_id"]
    end

    def batch
      return unless batch_job?

      @batch ||= BatchProcessor::BatchBase.find(batch_id)
    end

    def batch_job?
      batch_id.present?
    end

    private

    def batch_job_failure(exception)
      error :batch_job_failed, exception: exception, job_id: job_id
      batch.job_running unless tracked_batch_running
      batch.job_failure
    end
  end
end
