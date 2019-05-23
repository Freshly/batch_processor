# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Predicates, type: :module do
  include_context "with an example batch", described_class

  shared_examples_for "a detail" do |detail, source|
    subject { example_batch.public_send(detail) }

    let(:example_detail) { double }

    before { allow(example_batch.details).to receive(source).and_return(example_detail) }

    it { is_expected.to eq example_detail }
  end

  describe "#started?" do
    it_behaves_like "a detail", :started?, :started_at?
  end

  describe "#enqueued?" do
    it_behaves_like "a detail", :enqueued?, :enqueued_at?
  end

  describe "#aborted?" do
    it_behaves_like "a detail", :aborted?, :aborted_at?
  end

  describe "#ended?" do
    it_behaves_like "a detail", :ended?, :ended_at?
  end
end
