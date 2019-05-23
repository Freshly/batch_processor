# frozen_string_literal: true

# A batch can only be processed by a batchable job.
module BatchProcessor
  class BatchableJob < ActiveJob::Base
  end
end
