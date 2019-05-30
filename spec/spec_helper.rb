# frozen_string_literal: true

require "bundler/setup"
require "pry"
require "simplecov"

require "spicerack/spec_helper"
require "technologic/spec_helper"
require "shoulda-matchers"

SimpleCov.start do
  add_filter "/spec/"
end

require "batch_processor"

require_relative "support/shared_context/with_an_example_batch"
require_relative "support/shared_context/with_an_example_processor"
require_relative "support/shared_context/with_example_details"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) { Redis.new.flushdb }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
  end
end
