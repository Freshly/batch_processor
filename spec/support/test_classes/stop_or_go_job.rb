# frozen_string_literal: true

class StopOrGoJob < BatchProcessor::BatchJob
  def perform(color)
    raise StandardError if color != "green"
  end
end
