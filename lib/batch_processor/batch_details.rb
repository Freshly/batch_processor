# frozen_string_literal: true

require_relative "batch/details/callbacks"
require_relative "batch/details/core"
require_relative "batch/details/redis_connection"

module BatchProcessor
  class BatchDetails
    include ShortCircuIt
    include Technologic
    include BatchProcessor::Batch::Details::Callbacks
    include BatchProcessor::Batch::Details::Core
    include BatchProcessor::Batch::Details::RedisConnection
  end
end
