# frozen_string_literal: true

require "bundler/setup"
require "pry"
require "simplecov"

require "timecop"

require "spicerack/spec_helper"
require "shoulda-matchers"

SimpleCov.start do
  add_filter "/spec/"
end

require "batch_processor"

require_relative "support/shared_context/with_an_example_batch"
require_relative "support/shared_context/with_an_example_processor"
require_relative "support/shared_context/with_an_example_processor_batch"
require_relative "support/shared_examples/the_batch_must_be_processing"

require_relative "support/test_classes/fake_order"
require_relative "support/test_classes/charge_batch"
require_relative "support/test_classes/charge_job"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) { Redis.new.flushdb }

  config.before(:each, type: :job) { ActiveJob::Base.queue_adapter = :test }
  config.before(:each, type: :with_frozen_time) { Timecop.freeze(Time.now.round) }
  config.before(:each, type: :integration) do
    Timecop.freeze(Time.now.round)
    ActiveJob::Base.queue_adapter = :test
  end

  config.after(:each) { Timecop.return }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
  end
end

module ActiveJob
  module QueueAdapters
    class TestAdapter
      def job_to_hash(job, extras = {})
        serialized = job.serialize
        {
          job: job.class,
          args: serialized.fetch("arguments"),
          queue: job.queue_name,
          serialized: serialized
        }.merge!(extras)
      end
    end
  end
end
