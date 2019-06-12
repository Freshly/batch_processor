# frozen_string_literal: true

class TrafficLightJob < BatchProcessor::BatchJob
  class SlowError < StandardError; end
  class StopError < StandardError; end

  retry_on SlowError, queue: :other_queue
  discard_on StopError

  def perform(color)
    raise SlowError, queue_name if color == "yellow" && queue_name == "default"
    raise StopError, color if color == "red"
  end
end
