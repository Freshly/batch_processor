# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Predicates, type: :module do
  include_context "with an example batch", described_class

  shared_examples_for "a date predicate" do |detail, source|
    subject { example_batch.public_send(detail) }

    let(:example_detail) { double }

    before { allow(example_batch.details).to receive(source).and_return(example_detail) }

    it { is_expected.to eq example_detail }
  end

  shared_examples_for "a job count predicate" do |detail, source|
    subject { example_batch.public_send(detail) }

    before { allow(example_batch.details).to receive(source).and_return(example_value) }

    context "when less than zero" do
      let(:example_value) { -1 }

      it { is_expected.to eq false }
    end

    context "when zero" do
      let(:example_value) { 0 }

      it { is_expected.to eq false }
    end

    context "when greater than zero" do
      let(:example_value) { 1 }

      it { is_expected.to eq true }
    end
  end

  describe "#started?" do
    it_behaves_like "a date predicate", :started?, :started_at?
  end

  describe "#enqueued?" do
    it_behaves_like "a date predicate", :enqueued?, :enqueued_at?
  end

  describe "#aborted?" do
    it_behaves_like "a date predicate", :aborted?, :aborted_at?
  end

  describe "#finished?" do
    it_behaves_like "a date predicate", :finished?, :finished_at?
  end

  describe "#enqueued_jobs?" do
    it_behaves_like "a job count predicate", :enqueued_jobs?, :enqueued_jobs_count
  end

  describe "#canceled_jobs?" do
    it_behaves_like "a job count predicate", :canceled_jobs?, :canceled_jobs_count
  end

  describe "#unfinished_jobs?" do
    it_behaves_like "a job count predicate", :unfinished_jobs?, :unfinished_jobs_count
  end
end
