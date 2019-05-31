# frozen_string_literal: true

# Predicates allow inspection of the status of a batch.
module BatchProcessor
  module Batch
    module Predicates
      extend ActiveSupport::Concern

      included do
        date_predicate :started, :enqueued, :aborted, :finished

        job_count_predicate :enqueued, :pending, :running, :failed, :canceled, :unfinished, :finished
      end

      def processing?
        started? && !aborted? && !finished?
      end

      class_methods do
        private

        def date_predicate(*methods)
          methods.each do |method|
            define_method("#{method}?".to_sym) { details.public_send("#{method}_at?".to_sym) }
          end
        end

        def job_count_predicate(*methods)
          methods.each do |method|
            define_method("#{method}_jobs?".to_sym) { details.public_send("#{method}_jobs_count".to_sym) > 0 }
          end
        end
      end
    end
  end
end
