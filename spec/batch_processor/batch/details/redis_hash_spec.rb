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

    it { is_expected.to eq example_details }
  end

  shared_examples_for "the value is set in memory and redis" do
    it "writes to redis and in memory field" do
      expect { subject }.
        to change { Redis.new.hget("BatchProcessor:#{batch_id}", field) }.from(existing_value).to(value).
        and change { example_details.redis_hash[field] }.from(existing_value).to(value)
    end
  end

  describe "#[]=" do
    subject(:bracket_assignment) { example_details[field] = value }

    let(:field) { SecureRandom.hex }
    let(:value) { SecureRandom.hex }

    let(:existing_value) { nil }

    context "without existing value" do
      it_behaves_like "the value is set in memory and redis"
    end

    context "with existing value" do
      let(:existing_value) { SecureRandom.hex }

      before { Redis.new.hset("BatchProcessor:#{batch_id}", field, existing_value) }

      it_behaves_like "the value is set in memory and redis"
    end
  end

  describe "#merge" do
    let(:field1) { SecureRandom.hex }
    let(:value1) { SecureRandom.hex }
    let(:field2) { SecureRandom.hex }
    let(:value2) { SecureRandom.hex }

    shared_examples_for "the values are merged" do
      context "without existing value" do
        let(:existing_value) { nil }

        it_behaves_like "the value is set in memory and redis" do
          let(:field) { field1 }
          let(:value) { value1 }
        end

        it_behaves_like "the value is set in memory and redis" do
          let(:field) { field2 }
          let(:value) { value2 }
        end
      end

      context "with existing value" do
        let(:existing_value1) { SecureRandom.hex }

        before { Redis.new.hset("BatchProcessor:#{batch_id}", field1, existing_value1) }

        it_behaves_like "the value is set in memory and redis" do
          let(:field) { field1 }
          let(:value) { value1 }
          let(:existing_value) { existing_value1 }
        end

        it_behaves_like "the value is set in memory and redis" do
          let(:field) { field2 }
          let(:value) { value2 }
          let(:existing_value) { nil }
        end
      end
    end

    context "with kwargs" do
      subject(:merge) { example_details.merge(**{ field1 => value1, field2 => value2 }.symbolize_keys) }

      it_behaves_like "the values are merged"
    end

    context "with hash" do
      subject(:merge) { example_details.merge(field1 => value1, field2 => value2) }

      it_behaves_like "the values are merged"
    end
  end
end
