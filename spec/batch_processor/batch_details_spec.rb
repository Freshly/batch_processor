# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchDetails, type: :batch do
  subject(:batch_details) { described_class.new(batch_id) }

  let(:batch_id) { SecureRandom.hex }

  it { is_expected.to inherit_from RedisHash::Base }
  it { is_expected.to include_module Spicerack::HashModel }

  it { is_expected.to define_field :began_at, :datetime }
  it { is_expected.to define_field :enqueued_at, :datetime }
  it { is_expected.to define_field :aborted_at, :datetime }
  it { is_expected.to define_field :ended_at, :datetime }
  it { is_expected.to define_field :enqueued_jobs_count, :integer }
  it { is_expected.to define_field :pending_jobs_count, :integer }
  it { is_expected.to define_field :running_jobs_count, :integer }
  it { is_expected.to define_field :successful_jobs_count, :integer }
  it { is_expected.to define_field :failed_jobs_count, :integer }
  it { is_expected.to define_field :canceled_jobs_count, :integer }
  it { is_expected.to define_field :retried_jobs_count, :integer }
  it { is_expected.to define_field :cleared_jobs_count, :integer }

  it { is_expected.to allow_key :began_at }
  it { is_expected.to allow_key :enqueued_at }
  it { is_expected.to allow_key :aborted_at }
  it { is_expected.to allow_key :ended_at }
  it { is_expected.to allow_key :enqueued_jobs_count }
  it { is_expected.to allow_key :pending_jobs_count }
  it { is_expected.to allow_key :running_jobs_count }
  it { is_expected.to allow_key :successful_jobs_count }
  it { is_expected.to allow_key :failed_jobs_count }
  it { is_expected.to allow_key :canceled_jobs_count }
  it { is_expected.to allow_key :retried_jobs_count }
  it { is_expected.to allow_key :cleared_jobs_count }

  describe "#batch_id" do
    subject { batch_details.batch_id }

    it { is_expected.to eq batch_id }
  end

  describe "#data" do
    subject { batch_details.data }

    it { is_expected.to eq batch_details }
  end

  describe "#redis_key" do
    subject { batch_details.redis_key }

    it { is_expected.to eq described_class.redis_key_for_batch_id(batch_id) }
  end

  describe ".redis_key_for_batch_id" do
    subject { described_class.redis_key_for_batch_id(batch_id) }

    it { is_expected.to eq "#{described_class}::#{batch_id}" }
  end
end
