# frozen_string_literal: true

# A batch can only be processed by a batchable job.
module BatchProcessor
  class BatchJob < ActiveJob::Base
    attr_accessor :batch_id

    around_perform do |_job, block|
      block.call and next unless batch_job?

      # TODO: cancel if aborted...

      # TODO: job started...
      block.call
      # TODO: job success...
    end

    # Discard batch jobs which error as unexpectedly re-enqueued jobs can offset the counters
    discard_on StandardError do |_job, exception|
      raise exception unless batch_job?

      # TODO: job failed...
    end

    def retry_job(options = {})
      # TODO: job retried...
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

      @batch ||= BatchProcessor::BatchBase.new(batch_id: batch_id)
    end

    def batch_job?
      batch_id.present?
    end
  end
end
