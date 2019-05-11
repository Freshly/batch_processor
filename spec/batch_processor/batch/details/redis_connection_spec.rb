# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Details::RedisConnection, type: :module do
  include_context "with an example batch", described_class

  describe "#redis" do
    subject { example_batch.__send__(:redis) }

    it { is_expected.to be_an_instance_of Redis }
  end
end
