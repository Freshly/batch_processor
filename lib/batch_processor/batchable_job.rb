# frozen_string_literal: true

# A batch can only be processed by a batchable job.
module BatchProcessor
  module BatchableJob
    extend ActiveSupport::Concern
  end
end
