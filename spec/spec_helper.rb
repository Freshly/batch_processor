# frozen_string_literal: true

require "bundler/setup"
require "pry"
require "simplecov"

require "timecop"

require "spicerack/spec_helper"
require "shoulda-matchers"

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/rspec/"
end

require "batch_processor"

require_relative "../lib/batch_processor/spec_helper"
require_relative "../lib/batch_processor/rspec/active_job_test_adapter_monkeypatch"

require_relative "support/shared_context/with_an_example_batch"
require_relative "support/shared_context/with_an_example_processor"
require_relative "support/shared_context/with_an_example_processor_batch"
require_relative "support/shared_examples/the_batch_is_not_aborted"
require_relative "support/shared_examples/the_batch_is_started_and_enqueued"
require_relative "support/shared_examples/the_batch_must_be_processing"
require_relative "support/shared_examples/the_jobs_are_processed_as"

require_relative "support/test_classes/alerter"
require_relative "support/test_classes/default_job"
require_relative "support/test_classes/default_batch"
require_relative "support/test_classes/red_green_batch"
require_relative "support/test_classes/red_green_job"
require_relative "support/test_classes/traffic_light_batch"
require_relative "support/test_classes/traffic_light_job"
require_relative "support/test_classes/red_yellow_green_batch"
require_relative "support/test_classes/stop_or_go_batch"
require_relative "support/test_classes/stop_or_go_job"
require_relative "support/test_classes/always_go_batch"

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
