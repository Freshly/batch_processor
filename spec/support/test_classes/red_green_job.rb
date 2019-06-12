# frozen_string_literal: true

class RedGreenJob < BatchProcessor::BatchJob
  def perform(color)
    raise RuntimeError, color if color == "red"
  end
end
