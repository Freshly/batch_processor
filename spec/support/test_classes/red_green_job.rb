# frozen_string_literal: true

class RedGreenJob < BatchProcessor::BatchJob
  discard_on StandardError

  def perform(color)
    raise RuntimeError, color if color == "red"
  end
end
