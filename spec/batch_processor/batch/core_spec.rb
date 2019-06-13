# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Core, type: :module do
  include_context "with an example batch"

  describe "#batch_id" do
    before { allow(SecureRandom).to receive(:urlsafe_base64).with(10).and_return(:urlsafe_base64_mock) }

    it { is_expected.to define_option :batch_id, default: :urlsafe_base64_mock }
  end

  describe "#details" do
    subject(:details) { example_batch.details }

    it { is_expected.to be_an_instance_of BatchProcessor::BatchDetails }

    it "uses #batch_id" do
      expect(details.batch_id).to eq batch_id
    end
  end

  describe ".find" do
    subject(:find) { example_batch_class.find(batch_id) }

    let(:batch_id) { SecureRandom.hex }

    context "without a class_name" do
      it "raises" do
        expect { find }.to raise_error BatchProcessor::NotFoundError, "A Batch with id #{batch_id} was not found."
      end
    end

    context "with a class_name" do
      let(:redis_key) { BatchProcessor::BatchDetails.redis_key_for_batch_id(batch_id) }
      let(:class_name) { Faker::Internet.domain_word.capitalize }

      before { Redis.new.hset(redis_key, "class_name", class_name) }

      context "when invalid" do
        it "raises" do
          expect { find }.to raise_error BatchProcessor::ClassMissingError, "#{class_name} is not a class"
        end
      end

      context "when valid" do
        let(:class_name) { example_batch_name }

        it { is_expected.to be_an_instance_of example_batch_class }
        it { is_expected.to have_attributes(batch_id: batch_id) }
      end
    end
  end
end
