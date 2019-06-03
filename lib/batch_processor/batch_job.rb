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

    # Discard batch jobs which error as unexpectedly re-enqueued jobs can offset the counters
    discard_on StandardError do |job, exception|
      raise exception unless job.batch_job?

      job.batch.job_failure
    end

    discard_on(BatchAbortedError) { |job| job.batch.job_canceled }

    def serialize
      super.merge("batch_id" => batch_id) # rubocop:disable Style/StringHashKeys
    end

    def deserialize(job_data)
      super(job_data)
      self.batch_id = job_data["batch_id"]
    end

    def batch
      return unless batch_job?

      @batch ||= BatchProcessor::BatchBase.new(batch_id: batch_id)
    end

    def batch_job?
      batch_id.present?
    end
  end
end
