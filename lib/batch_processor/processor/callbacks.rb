# frozen_string_literal: true

# Callbacks provide an extensible mechanism for hooking into a Processor.
module BatchProcessor
  module Processor
    module Callbacks
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks
        define_callbacks :execute, :start, :job_perform, :finish
      end
    end
  end
end