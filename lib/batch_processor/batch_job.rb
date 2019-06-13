# frozen_string_literal: true

# A batch can only be processed by a batchable job.
module BatchProcessor
  class BatchJob < ActiveJob::Base
    attr_accessor :batch_id

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

      batch.job_running
    end

    after_perform(if: :batch_job?) { batch.job_success }

    def rescue_with_handler(exception)
      batch.job_canceled and return exception if exception.is_a?(BatchAbortedError)

      batch.job_failure if batch_job?

      result = super
      result ||= exception if batch_job?
      result
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
  end
end
