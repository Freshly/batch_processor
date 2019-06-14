# frozen_string_literal: true

# RSpec matcher that tests usages of batches which do not specify a processor
#
#     class ExampleBatch < ApplicationBatch
#     end
#
#     RSpec.describe ExampleBatch do
#       it { is_expected.to use_default_processor }
#     end

RSpec::Matchers.define :use_default_processor do
  match { is_expected.to use_batch_processor_strategy :default }
end
