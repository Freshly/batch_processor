# frozen_string_literal: true

RSpec.shared_examples_for "the batch is started and enqueued" do
  it "has expected flags and dates" do
    expect(batch).to be_started
    expect(batch).to be_enqueued
    expect(details).to have_attributes(started_at: Time.current, enqueued_at: Time.current)
  end
end
