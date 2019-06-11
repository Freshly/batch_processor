# frozen_string_literal: true

class ChargeJob < BatchProcessor::BatchJob
  def perform(id)
    puts "doing things"
  end
end
