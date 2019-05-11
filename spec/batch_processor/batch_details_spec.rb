# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchDetails, type: :batch do
  subject { described_class }

  it { is_expected.to include_module ShortCircuIt }
  it { is_expected.to include_module Technologic }
  it { is_expected.to include_module BatchProcessor::Batch::Details::Callbacks }
  it { is_expected.to include_module BatchProcessor::Batch::Details::Core }
  it { is_expected.to include_module BatchProcessor::Batch::Details::RedisHash }
end
