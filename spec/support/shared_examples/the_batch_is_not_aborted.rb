# frozen_string_literal: true

RSpec.shared_examples_for "the batch is not aborted" do
  it "is not aborted" do
    expect(batch).not_to be_aborted
    expect(details.aborted_at).to be_nil
  end
end
