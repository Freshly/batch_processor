# frozen_string_literal: true

class RedYellowGreenBatch < BatchProcessor::BatchBase
  with_parallel_processor
  process_with_job TrafficLightJob

  on_batch_started :handle_batch_started
  on_batch_enqueued :handle_batch_enqueued
  on_batch_aborted :handle_batch_aborted
  on_batch_finished { Alerter.new.increment(:count_batch_finished) }

  on_job_enqueued { Alerter.new.increment(:count_job_enqueued) }
  on_job_running { Alerter.new.increment(:count_job_running) }
  on_job_retried { Alerter.new.increment(:count_job_retried) }
  on_job_canceled { Alerter.new.increment(:count_job_canceled) }
  on_job_success { Alerter.new.increment(:count_job_success) }
  on_job_failure :handle_job_failure

  class Collection < BatchCollection
    def items
      %w[red yellow green]
    end
  end

  private

  def handle_batch_started
    Alerter.new.increment(:count_batch_started)
  end

  def handle_batch_enqueued
    Alerter.new.increment(:count_batch_enqueued)
  end

  def handle_batch_aborted
    Alerter.new.increment(:count_batch_aborted)
  end

  def handle_job_failure
    Alerter.new.increment(:count_job_failure)
  end
end
