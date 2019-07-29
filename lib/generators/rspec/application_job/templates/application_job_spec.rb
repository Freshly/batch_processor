# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  it { is_expected.to inherit_from BatchProcessor::BatchJob }
end

