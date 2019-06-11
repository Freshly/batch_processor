# frozen_string_literal: true

class ChargeBatch < BatchProcessor::BatchBase
  allow_empty
  with_parallel_processor

  argument :charge_day, allow_nil: false

  def build_collection
    FakeOrder.where(charge_day: charge_day)
  end

  def collection_item_to_job_params(fake_order)
    { id: fake_order.id, charge_day: fake_order.charge_day.to_s }
  end
end
