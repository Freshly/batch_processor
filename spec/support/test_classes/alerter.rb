# frozen_string_literal: true

class Alerter < Spicerack::RedisModel
  field :count_batch_started, :integer, default: 0
  field :count_batch_enqueued, :integer, default: 0
  field :count_batch_aborted, :integer, default: 0
  field :count_batch_finished, :integer, default: 0

  field :count_job_enqueued, :integer, default: 0
  field :count_job_running, :integer, default: 0
  field :count_job_retried, :integer, default: 0
  field :count_job_canceled, :integer, default: 0
  field :count_job_success, :integer, default: 0
  field :count_job_failure, :integer, default: 0

  def default_redis_key
    :test_alerter
  end
end
