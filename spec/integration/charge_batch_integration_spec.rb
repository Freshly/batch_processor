# frozen_string_literal: true

RSpec.describe ChargeBatch, type: :integration do
  let(:enqueued_jobs) { ActiveJob::Base.queue_adapter.enqueued_jobs }

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
    let(:expected_size) { batch.collection.count }

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

      describe "#total_jobs_count" do
        subject { details.total_jobs_count }

        it { is_expected.to eq expected_size }
      end
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

      shared_examples_for "jobs are processed as" do |result|
        let(:result_count) { "#{result}_jobs_count".to_sym }

        it "handles counts as jobs are processed" do
          enqueued_jobs.take(2).each do |job|
            expect { ActiveJob::Base.execute job }.
              to change { details.pending_jobs_count }.by(-1).
              and change { details.public_send(result_count) }.by(1).
              and change { details.finished_jobs_count }.by(1)
          end
        end

        it "completes the batch when all jobs finish" do
          expect { enqueued_jobs.each(&ActiveJob::Base.method(:execute)) }.
          to change { details.pending_jobs_count }.by(-expected_size).
          and change { details.public_send(result_count) }.by(expected_size).
          and change { details.finished_at }.from(nil).to(Time.current).
          and change { batch.finished? }.from(false).to(true)
        end
      end

      context "when all jobs succeed" do
        it_behaves_like "jobs are processed as", :successful
      end

      context "when all jobs fail" do
        let(:charge_day) { Date.new(1986, 04, 18) }

        it_behaves_like "jobs are processed as", :failed
      end

      context "when the batch is aborted" do
        before { batch.abort! }

        it_behaves_like "jobs are processed as", :canceled
      end
    end
  end
end
