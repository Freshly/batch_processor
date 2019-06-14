# frozen_string_literal: true

# RSpec matcher that tests usages of batches which do not specify a processor
#
#     class ExampleBatch < ApplicationBatch
#       processor_option :sorted, true
#     end
#
#     RSpec.describe ExampleBatch do
#       it { is_expected.to set_processor_option :sorted, true }
#     end

RSpec::Matchers.define :set_processor_option do |key, value|
  match { expect(test_subject._processor_options[key]).to eq value }
  description { "set processor option #{key}" }
  failure_message { "expected #{test_subject} to set processor option #{key} to #{value}" }
  failure_message_when_negated { "expected #{test_subject} not to set processor option #{key} to #{value}" }

  def test_subject
    subject.is_a?(Class) ? subject : subject.class
  end
end
