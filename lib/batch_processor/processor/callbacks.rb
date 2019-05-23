# frozen_string_literal: true

# Callbacks provide an extensible mechanism for hooking into a Processor.
module BatchProcessor
  module Processor
    module Callbacks
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks
        define_callbacks :started, :job_performed, :finished
      end
    end
  end
end
