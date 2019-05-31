# frozen_string_literal: true

# A batch can only be processed by a batchable job.
module BatchProcessor
  class BatchJob < ActiveJob::Base
    attr_accessor :batch_id

    # after_enqueue(if: :batch_job?) do |job|
    #   case job.executions
    #   when 0
    #     # TODO: job_enqueued
    #   when 1
    #     # TODO: job_retried
    #     # TODO: total_retries
    #   else
    #     # TODO: total_retries
    #   end
    # end
    #
    # before_perform(if: :batch_job?) do |job|
    #   if job.batch.aborted?
    #     # TODO: job_canceled
    #   else
    #     # TODO: job_running
    #   end
    # end
    #
    # after_perform(if: :batch_job?) do |_job|
    #   # TODO: job_success
    # end
    #
    # # Discard batch jobs which error as unexpectedly re-enqueued jobs can offset the counters
    # discard_on StandardError do |_job, exception|
    #   raise exception unless batch_job?
    #
    #   # TODO: job_failure
    # end

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
