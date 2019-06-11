# frozen_string_literal: true

RSpec.describe ChargeBatch, type: :integration do
  context "without any arguments" do
    subject(:process) { described_class.process }

    it "raises" do
      expect { process }.to raise_error ArgumentError, "Missing argument: charge_day"
    end
  end

  context "with a charge_day" do
    subject(:process) { batch.process }

    let(:batch) { described_class.new(charge_day: charge_day) }
    let(:details) { batch.details }

    shared_examples_for "it's started, enqueued, and not aborted" do
      it "has expected flags and dates" do
        expect(batch).to be_started
        expect(batch).to be_enqueued
        expect(batch).not_to be_aborted
        expect(details).to have_attributes(started_at: Time.current, enqueued_at: Time.current, aborted_at: nil)
      end
    end

    shared_examples_for "the counts are expected" do
      subject { details }

      let(:expected_size) { batch.collection.count }

      let(:expected_attributes) do
        { size: expected_size,
          enqueued_jobs_count: expected_size,
          pending_jobs_count: expected_size,
          running_jobs_count: 0,
          total_retries_count: 0,
          successful_jobs_count: 0,
          failed_jobs_count: 0,
          canceled_jobs_count: 0,
          cleared_jobs_count: 0 }
      end

      it { is_expected.to have_attributes expected_attributes }
    end

    context "when the collection is empty" do
      let(:charge_day) { :zero }

      before { process }

      it_behaves_like "it's started, enqueued, and not aborted"
      it_behaves_like "the counts are expected"

      it "is finished" do
        expect(batch).to be_finished
        expect(details.finished_at).to eq Time.current
      end
    end

    context "with a collection of data" do
      let(:charge_day) { Date.current }

      before { process }

      it_behaves_like "it's started, enqueued, and not aborted"
      it_behaves_like "the counts are expected"

      it "remains unfinished" do
        expect(batch).not_to be_finished
        expect(details.finished_at).to be_nil
      end
    end
  end
end
