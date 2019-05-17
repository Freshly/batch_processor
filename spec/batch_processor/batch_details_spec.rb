# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchDetails, type: :batch do
  subject { described_class }

  it { is_expected.to inherit_from RedisHash::Base }
end
