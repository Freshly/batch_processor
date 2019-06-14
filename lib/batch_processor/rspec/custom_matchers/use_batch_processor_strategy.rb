# frozen_string_literal: true

# RSpec matcher to DRY out the similarities between the other batch processor matchers.
#
#     class ExampleBatch < ApplicationBatch
#     end
#
#     RSpec.describe ExampleBatch do
#       it { is_expected.to use_batch_processor_strategy :default }
#     end

RSpec::Matchers.define :use_batch_processor_strategy do |strategy|
  match { test_subject.processor_class == BatchProcessor::Batch::Processor::PROCESSOR_CLASS_BY_STRATEGY[strategy] }
  description { "use #{strategy} processor" }
  failure_message { "expected #{test_subject} to use #{strategy} processor" }
  failure_message_when_negated { "expected #{test_subject} not to use #{strategy} processor" }

  def test_subject
    subject.is_a?(Class) ? subject : subject.class
  end
end
