# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Details::RedisHash, type: :module do
  include_context "with example details", described_class

  it { is_expected.to alias_method :reload, :reload_redis_hash }

  describe "#redis" do
    subject { example_details.redis }

    it { is_expected.to be_an_instance_of Redis }
  end

  describe "#redis_key" do
    subject { example_details.redis_key }

    it { is_expected.to eq "BatchProcessor:#{batch_id}" }
  end

  describe "#persisted?" do
    subject { example_details.persisted? }

    before { allow(example_details).to receive(:redis_hash).and_return(redis_hash) }

    context "with #redis_hash" do
      let(:redis_hash) do
        { present: true }
      end

      it { is_expected.to eq true }
    end

    context "without #redis_hash" do
      let(:redis_hash) { {} }

      it { is_expected.to eq false }
    end
  end

  describe "#redis_hash" do
    subject { example_details.redis_hash }

    context "with nothing in redis" do
      it { is_expected.to eq({}) }
    end

    context "with values in redis" do
      let(:hash_key) { SecureRandom.hex }
      let(:hash_value) { SecureRandom.hex }

      before { Redis.new.hset("BatchProcessor:#{batch_id}", hash_key, hash_value) }

      it { is_expected.to eq(hash_key => hash_value) }
    end
  end

  describe "#reload_redis_hash" do
    subject(:reload_redis_hash) { example_details.reload_redis_hash }

    let(:hash_key) { SecureRandom.hex }
    let(:hash_value) { SecureRandom.hex }

    let(:new_hash_key) { SecureRandom.hex }
    let(:new_hash_value) { SecureRandom.hex }

    let(:original_hash) { example_details.redis_hash }
    let(:new_hash) { original_hash.merge(new_hash_key => new_hash_value) }

    before do
      Redis.new.hset("BatchProcessor:#{batch_id}", hash_key, hash_value)
      original_hash
    end

    it "reloads from redis" do
      Redis.new.hset("BatchProcessor:#{batch_id}", new_hash_key, new_hash_value)
      expect { reload_redis_hash }.to change { example_details.redis_hash }.from(original_hash).to(new_hash)
    end
  end
end
