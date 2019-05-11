# frozen_string_literal: true

# Callbacks provide an extensible mechanism for hooking into a Batch.
module BatchProcessor
  module Batch
    module Callbacks
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks
        define_callbacks :initialize
        define_callbacks_with_handler :job_started, :job_retrying, :job_performed, :job_canceled,
                                      :batch_aborted, :batch_finished, :batch_success, :batch_errored, :batch_completed
      end

      class_methods do
        private

        def define_callbacks_with_handler(*events, handler: :on, filter: :after)
          define_callbacks(*events)

          events.each do |event|
            define_singleton_method("#{handler}_#{event}".to_sym) do |*filters, &block|
              set_callback(event, filter, *filters, &block)
            end
          end
        end
      end
    end
  end
end
