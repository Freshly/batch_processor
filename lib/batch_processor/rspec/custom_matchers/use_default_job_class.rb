# frozen_string_literal: true

# RSpec matcher that tests usages of batches which do not explicitly specify a job.
#
#     class ExampleBatch < ApplicationBatch
#     end
#
#     RSpec.describe ExampleBatch do
#       it { is_expected.to use_default_job_class }
#     end

RSpec::Matchers.define :use_default_job_class do
  match { is_expected.to use_job_class "#{test_subject.name.chomp("Batch")}Job".constantize }

  def test_subject
    subject.is_a?(Class) ? subject : subject.class
  end
end
