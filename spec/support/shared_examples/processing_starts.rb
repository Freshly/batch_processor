# frozen_string_literal: true

RSpec.shared_examples_for "processing starts" do
  before { allow(example_batch).to receive(:collection).and_return(collection) }

  let(:collection) { Faker::Lorem.words }

  it "starts processing the batch" do
    expect { subject }.
      to change { example_batch.started? }.from(false).to(true).
      and change { example_batch.details.started_at&.change(usec: 0) }.from(nil).to(Time.current.change(usec: 0)).
      and change { example_batch.details.size }.from(0).to(collection.size)
  end
end
