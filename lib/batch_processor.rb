# frozen_string_literal: true

require "active_support"
require "active_job"

require "spicerack"

require "batch_processor/version"
require "batch_processor/batchable_job"
require "batch_processor/batch_details"
require "batch_processor/processor_base"
require "batch_processor/batch_base"

module BatchProcessor
  class Error < StandardError; end
  class BatchError < Error; end
  class ProcessorError < Error; end

  class ExistingBatchError < BatchError; end

  class BatchEmptyError < ProcessorError; end
  class BatchAlreadyStartedError < ProcessorError; end
  class BatchAlreadyFinishedError < ProcessorError; end
  class BatchStillProcessingError < ProcessorError; end
end
