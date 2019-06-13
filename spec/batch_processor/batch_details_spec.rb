# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchDetails, type: :batch do
  subject(:batch_details) { described_class.new(batch_id) }

  let(:batch_id) { SecureRandom.hex }

  it { is_expected.to inherit_from Spicerack::RedisModel }

  it { is_expected.to define_field :class_name, :string }

  it { is_expected.to define_field :started_at, :datetime }
  it { is_expected.to define_field :enqueued_at, :datetime }
  it { is_expected.to define_field :aborted_at, :datetime }
  it { is_expected.to define_field :finished_at, :datetime }

  it { is_expected.to define_field :size, :integer, default: 0 }
  it { is_expected.to define_field :enqueued_jobs_count, :integer, default: 0 }
  it { is_expected.to define_field :pending_jobs_count, :integer, default: 0 }
  it { is_expected.to define_field :running_jobs_count, :integer, default: 0 }
  it { is_expected.to define_field :successful_jobs_count, :integer, default: 0 }
  it { is_expected.to define_field :failed_jobs_count, :integer, default: 0 }
  it { is_expected.to define_field :canceled_jobs_count, :integer, default: 0 }
  it { is_expected.to define_field :cleared_jobs_count, :integer, default: 0 }
  it { is_expected.to define_field :total_retries_count, :integer, default: 0 }

  it { is_expected.to allow_key :started_at }
  it { is_expected.to allow_key :enqueued_at }
  it { is_expected.to allow_key :aborted_at }
  it { is_expected.to allow_key :finished_at }

  it { is_expected.to allow_key :size }
  it { is_expected.to allow_key :enqueued_jobs_count }
  it { is_expected.to allow_key :pending_jobs_count }
  it { is_expected.to allow_key :running_jobs_count }
  it { is_expected.to allow_key :successful_jobs_count }
  it { is_expected.to allow_key :failed_jobs_count }
  it { is_expected.to allow_key :canceled_jobs_count }
  it { is_expected.to allow_key :cleared_jobs_count }
  it { is_expected.to allow_key :total_retries_count }

  describe "#batch_id" do
    subject { batch_details.batch_id }

    it { is_expected.to eq batch_id }
  end

  describe "#redis_key" do
    subject { batch_details.redis_key }

    it { is_expected.to eq described_class.redis_key_for_batch_id(batch_id) }
  end

  describe ".redis_key_for_batch_id" do
    subject { described_class.redis_key_for_batch_id(batch_id) }

    it { is_expected.to eq "#{described_class}::#{batch_id}" }
  end

  describe ".class_name_for_batch_id" do
    subject { described_class.class_name_for_batch_id(batch_id) }

    context "with nothing in redis" do
      it { is_expected.to be_nil }
    end

    context "with a value in redis" do
      before { Redis.new.hset(described_class.redis_key_for_batch_id(batch_id), "class_name", class_name) }

      let(:class_name) { "#{Faker::Internet.domain_word.capitalize}Batch" }

      it { is_expected.to eq class_name }
    end
  end

  shared_context "with job counts" do
    # These numbers are meant to ensure we don't get weird unexpected overlaps.
    # It's binary math to test only the right counts are actually involved in the calculation.
    let(:size) { 100_000_000 }
    let(:enqueued_jobs_count) { 10_000_000 }
    let(:pending_jobs_count) { 1_000_000 }
    let(:running_jobs_count) { 100_000 }
    let(:successful_jobs_count) { 10_000 }
    let(:failed_jobs_count) { 1_000 }
    let(:canceled_jobs_count) { 100 }
    let(:cleared_jobs_count) { 10 }
    let(:total_retries_count) { 1 }

    before do
      batch_details.pipelined do
        batch_details.size = size
        batch_details.enqueued_jobs_count = enqueued_jobs_count
        batch_details.pending_jobs_count = pending_jobs_count
        batch_details.running_jobs_count = running_jobs_count
        batch_details.successful_jobs_count = successful_jobs_count
        batch_details.failed_jobs_count = failed_jobs_count
        batch_details.canceled_jobs_count = canceled_jobs_count
        batch_details.cleared_jobs_count = cleared_jobs_count
        batch_details.total_retries_count = total_retries_count
      end
    end
  end

  shared_examples_for "a sum of counts" do |method|
    subject { batch_details.public_send(method) }

    let(:expected_sum) { [] }

    context "without data" do
      it { is_expected.to eq 0 }
    end

    context "with data" do
      include_context "with job counts"

      it { is_expected.to eq expected_sum }
    end
  end

  describe "#unfinished_jobs_count" do
    it_behaves_like "a sum of counts", :unfinished_jobs_count do
      let(:expected_sum) { pending_jobs_count + running_jobs_count }
    end
  end

  describe "#finished_jobs_count" do
    it_behaves_like "a sum of counts", :finished_jobs_count do
      let(:expected_sum) { successful_jobs_count + failed_jobs_count + canceled_jobs_count }
    end
  end

  describe "#total_jobs_count" do
    it_behaves_like "a sum of counts", :total_jobs_count do
      let(:expected_sum) do
        pending_jobs_count +
        running_jobs_count +
        successful_jobs_count +
        failed_jobs_count +
        canceled_jobs_count +
        cleared_jobs_count
      end
    end
  end
end
