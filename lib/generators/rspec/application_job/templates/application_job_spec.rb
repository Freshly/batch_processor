# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationBatch, type: :batch do
  it { is_expected.to inherit_from BatchProcessor::BatchBase }
end

