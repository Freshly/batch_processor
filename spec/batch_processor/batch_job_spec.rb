# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchJob, type: :job do
  subject(:batch_job) { described_class.new(*arguments) }

  let(:batch_id) { SecureRandom.hex }
  let(:arguments) { Faker::Lorem.words }

  it { is_expected.to inherit_from ActiveJob::Base }

  describe "#serialize" do
    subject { batch_job.serialize }

    before { batch_job.batch_id = batch_id }

    let(:expected_fragment) { Hash["arguments", arguments, "batch_id", batch_id] }

    context "without a batch" do
      let(:batch_id) { nil }

      it { is_expected.to include expected_fragment }
    end

    context "with a batch" do
      it { is_expected.to include expected_fragment }
    end
  end

  describe "#deserialize" do
    subject(:deserialize) { batch_job.deserialize(serialized_hash_fragment) }

    let(:job_id) { SecureRandom.hex }
    let(:batch_job) { described_class.new }
    let(:serialized_hash_fragment) { Hash["job_id", job_id, "batch_id", batch_id] }

    context "without a batch" do
      let(:batch_id) { nil }

      it "deserializes arguments" do
        expect { deserialize }.to change { batch_job.job_id }.to(job_id)
      end
    end

    context "with a batch" do
      it "deserializes attributes" do
        expect { deserialize }.to change { batch_job.batch_id }.to(batch_id).and change { batch_job.job_id }.to(job_id)
      end
    end
  end

  describe "#batch" do
    subject { batch_job.batch }

    before { batch_job.batch_id = batch_id }

    context "without a batch" do
      let(:batch_id) { nil }

      it { is_expected.to be_nil }
    end

    context "with a batch" do
      it { is_expected.to be_an_instance_of BatchProcessor::BatchBase }
      it { is_expected.to have_attributes(batch_id: batch_id) }
    end
  end

  describe "#batch_job?" do
    subject { batch_job.batch_job? }

    before { batch_job.batch_id = batch_id }

    context "without a batch" do
      let(:batch_id) { nil }

      it { is_expected.to eq false }
    end

    context "with a batch" do
      it { is_expected.to eq true }
    end
  end
end
