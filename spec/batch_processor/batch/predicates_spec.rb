# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Predicates, type: :module do
  include_context "with an example batch"

  it { is_expected.to delegate_method(:valid?).to(:collection).with_prefix(true) }

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

  describe "#aborted?" do
    it_behaves_like "a date predicate", :cleared?, :cleared_at?
  end

  describe "#finished?" do
    it_behaves_like "a date predicate", :finished?, :finished_at?
  end

  describe "#enqueued_jobs?" do
    it_behaves_like "a job count predicate", :enqueued_jobs?, :enqueued_jobs_count
  end

  describe "#pending_jobs?" do
    it_behaves_like "a job count predicate", :pending_jobs?, :pending_jobs_count
  end

  describe "#running_jobs?" do
    it_behaves_like "a job count predicate", :running_jobs?, :running_jobs_count
  end

  describe "#failed_jobs?" do
    it_behaves_like "a job count predicate", :failed_jobs?, :failed_jobs_count
  end

  describe "#canceled_jobs?" do
    it_behaves_like "a job count predicate", :canceled_jobs?, :canceled_jobs_count
  end

  describe "#canceled_jobs?" do
    it_behaves_like "a job count predicate", :canceled_jobs?, :canceled_jobs_count
  end

  describe "#unfinished_jobs?" do
    it_behaves_like "a job count predicate", :unfinished_jobs?, :unfinished_jobs_count
  end

  describe "#finished_jobs?" do
    it_behaves_like "a job count predicate", :finished_jobs?, :finished_jobs_count
  end

  describe "#processing?" do
    context "when not started" do
      it { is_expected.not_to be_processing }
    end

    context "when started" do
      before { example_batch.details.started_at = Time.current }

      context "when aborted" do
        before { example_batch.details.aborted_at = Time.current }

        it { is_expected.not_to be_processing }
      end

      context "when not aborted" do
        context "when finished" do
          before { example_batch.details.finished_at = Time.current }

          it { is_expected.not_to be_processing }
        end

        context "when not finished" do
          it { is_expected.to be_processing }
        end
      end
    end
  end

  describe "#malfunction?" do
    subject { example_batch }

    context "with malfunction" do
      let(:malfunction) { instance_double(BatchProcessor::Malfunction::Base) }

      before { allow(example_batch).to receive(:malfunction).and_return(malfunction) }

      it { is_expected.to be_malfunction }
    end

    context "without malfunction" do
      it { is_expected.not_to be_malfunction }
    end
  end
end
