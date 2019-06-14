# frozen_string_literal: true

RSpec.shared_context "with an example batch" do
  subject(:example_batch) { example_batch_class.new(batch_id: batch_id, **input) }

  let(:example_batch_class) { Class.new(BatchProcessor::BatchBase) }

  let(:batch_id) { SecureRandom.hex }
  let(:input) do
    {}
  end

  let(:root_name) { Faker::Internet.domain_word.capitalize }
  let(:example_batch_name) { "#{root_name}Batch" }

  before { stub_const(example_batch_name, example_batch_class) }
end
