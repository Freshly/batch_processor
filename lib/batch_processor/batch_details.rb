# frozen_string_literal: true

require_relative "batch/details/callbacks"
require_relative "batch/details/core"
require_relative "batch/details/redis_hash"
require_relative "batch/details/status"

module BatchProcessor
  class BatchDetails
    include ShortCircuIt
    include Technologic
    include BatchProcessor::Batch::Details::Callbacks
    include BatchProcessor::Batch::Details::Core
    include BatchProcessor::Batch::Details::RedisHash
    include BatchProcessor::Batch::Details::Status
  end
end
