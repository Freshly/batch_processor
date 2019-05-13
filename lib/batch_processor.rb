# frozen_string_literal: true

require "active_support"
require "active_job"

require "redis"

require "instructor"
require "short_circu_it"
require "technologic"

require "batch_processor/version"
require "batch_processor/batch_base"
require "batch_processor/batch_details"

module BatchProcessor
  class Error < StandardError; end

  class ExistingBatchError < Error; end
end
