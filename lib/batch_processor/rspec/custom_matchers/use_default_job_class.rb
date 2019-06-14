# frozen_string_literal: true

# RSpec matcher to DRY out the similarities between the other batch processor matchers.
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
