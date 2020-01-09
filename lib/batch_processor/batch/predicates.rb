# frozen_string_literal: true

# The **Status** of a batch is manifested by a collection of predicates which track certain lifecycle events.
module BatchProcessor
  module Batch
    module Predicates
      extend ActiveSupport::Concern

      included do
        date_predicate :started, :enqueued, :aborted, :cleared, :finished

        job_count_predicate :enqueued, :pending, :running, :failed, :canceled, :unfinished, :finished

        delegate :valid?, to: :collection, prefix: true
      end

      def processing?
        started? && !aborted? && !finished?
      end

      def malfunction?
        malfunction.present?
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
