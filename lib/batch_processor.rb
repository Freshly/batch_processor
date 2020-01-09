# frozen_string_literal: true

require "active_support"
require "active_job"

require "spicery"
require "malfunction"

require "batch_processor/malfunction/base"
require "batch_processor/malfunction/collection_empty"
require "batch_processor/malfunction/collection_invalid"
require "batch_processor/malfunction/already_started"
require "batch_processor/malfunction/already_enqueued"
require "batch_processor/malfunction/already_finished"
require "batch_processor/malfunction/already_aborted"
require "batch_processor/malfunction/already_cleared"

require "batch_processor/version"
require "batch_processor/batch_job"
require "batch_processor/batch_details"
require "batch_processor/processor_base"
require "batch_processor/processors/parallel"
require "batch_processor/processors/sequential"
require "batch_processor/collection"
require "batch_processor/batch_base"

module BatchProcessor
  class Error < StandardError
    include Conjunction::Junction
    prefixed_with "BatchProcessor::"
    suffixed_with "Error"
  end

  class NotFoundError < Error; end
  class ClassMissingError < Error; end
  class CollectionEmptyError < Error; end
  class CollectionInvalidError < Error; end
  class AlreadyStartedError < Error; end
  class AlreadyEnqueuedError < Error; end
  class AlreadyFinishedError < Error; end
  class AlreadyAbortedError < Error; end
  class AlreadyClearedError < Error; end
  class StillProcessingError < Error; end
  class NotProcessingError < Error; end
  class NotAbortedError < Error; end
  class NotStartedError < Error; end
end
