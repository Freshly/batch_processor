# frozen_string_literal: true

# RSpec matcher that tests usages of `.with_sequential_processor`.
#
#     class ExampleBatch < ApplicationBatch
#       with_sequential_processor
#     end
#
#     RSpec.describe ExampleBatch do
#       it { is_expected.to use_sequential_processor }
#     end

RSpec::Matchers.define :use_sequential_processor do
  match { is_expected.to use_batch_processor_strategy :sequential }
end
