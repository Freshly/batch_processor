# frozen_string_literal: true

RSpec.describe BatchProcessor::BatchBase, type: :batch do
  it { is_expected.to inherit_from Spicerack::InputModel }

  describe "#batch_id" do
    before { allow(SecureRandom).to receive(:urlsafe_base64).with(10).and_return(:urlsafe_base64_mock) }

    it { is_expected.to define_option :batch_id, default: :urlsafe_base64_mock }
  end

  describe "#details" do
    subject(:details) { batch.details }

    let(:batch) { described_class.new }

    it { is_expected.to be_an_instance_of BatchProcessor::BatchDetails }

    it "uses #batch_id" do
      expect(details.batch_id).to eq batch.batch_id
    end
  end

  it { is_expected.to include_module BatchProcessor::Batch::Collection }
  it { is_expected.to include_module BatchProcessor::Batch::Job }
  it { is_expected.to include_module BatchProcessor::Batch::Processor }
  it { is_expected.to include_module BatchProcessor::Batch::Predicates }
  it { is_expected.to include_module BatchProcessor::Batch::Controller }
end
