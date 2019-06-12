# frozen_string_literal: true

RSpec.shared_examples_for "jobs are processed as" do |result|
  it_behaves_like "the batch is started and enqueued"
  it_behaves_like "the counts are expected"

  it "remains unfinished" do
    expect(batch).not_to be_finished
    expect(details.finished_at).to be_nil
  end

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
