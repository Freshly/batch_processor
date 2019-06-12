# frozen_string_literal: true

# RSpec matcher to DRY out the similarities between the other batch processor matchers.
#
#     class ExampleBatch < ApplicationBatch
#       def self.job_class
#         SpecialJobClass
#       end
#     end
#
#     RSpec.describe ExampleBatch do
#       it { is_expected.to use_job_class SpecialJobClass }
#     end

RSpec::Matchers.define :use_job_class do |job_class|
  match { test_subject.job_class == job_class }
  description { "use #{job_class} job" }
  failure_message { "expected #{test_subject} to use #{job_class} job" }
  failure_message_when_negated { "expected #{test_subject} not to use #{job_class} job" }

  def test_subject
    subject.is_a?(Class) ? subject : subject.class
  end
end
