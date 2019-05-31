# frozen_string_literal: true

require "active_support"
require "active_job"

require "spicerack"

require "batch_processor/version"
require "batch_processor/batch_job"
require "batch_processor/batch_details"
require "batch_processor/processor_base"
require "batch_processor/processors/parallel"
require "batch_processor/processors/sequential"
require "batch_processor/batch_base"

module BatchProcessor
  class Error < StandardError; end

  class BatchError < Error; end
  class ExistingBatchError < BatchError; end
  class BatchEmptyError < BatchError; end
  class BatchAlreadyStartedError < BatchError; end
  class BatchAlreadyFinishedError < BatchError; end
  class BatchAlreadyEnqueuedError < BatchError; end
  class BatchStillProcessingError < BatchError; end
  class BatchNotProcessingError < BatchError; end

  class ProcessorError < Error; end
end
