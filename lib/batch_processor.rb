# frozen_string_literal: true

require "active_support"
require "active_job"

require "spicerack"

require "batch_processor/version"
require "batch_processor/batch_base"
require "batch_processor/batchable_job"
require "batch_processor/batch_details"

module BatchProcessor
  class Error < StandardError; end

  class ExistingBatchError < Error; end
end
