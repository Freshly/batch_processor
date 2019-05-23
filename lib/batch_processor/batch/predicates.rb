# frozen_string_literal: true

# Predicates allow inspection of the status of a batch.
module BatchProcessor
  module Batch
    module Predicates
      extend ActiveSupport::Concern

      included do
        date_predicate :started
        date_predicate :enqueued
        date_predicate :aborted
        date_predicate :ended
      end

      class_methods do
        private

        def date_predicate(method)
          define_method("#{method}?".to_sym) { details.public_send("#{method}_at?".to_sym) }
        end
      end
    end
  end
end
