# frozen_string_literal: true

class ChargeJob < BatchProcessor::BatchJob
  def perform(options)
    raise RuntimeError, "That's a great day!" if options[:charge_day] == "1986-04-18"
  end
end
