# frozen_string_literal: true

# RSpec matcher that tests usages of `.with_parallel_processor`.
#
#     class ExampleBatch < ApplicationBatch
#       with_parallel_processor
#     end
#
#     RSpec.describe ExampleBatch do
#       it { is_expected.to use_parallel_processor }
#     end

RSpec::Matchers.define :use_parallel_processor do
  match { is_expected.to use_batch_processor_strategy :parallel }
end
