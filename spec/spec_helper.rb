# frozen_string_literal: true

require "bundler/setup"
require "pry"
require "simplecov"

require "rspice"
require "shoulda-matchers"

SimpleCov.start do
  add_filter "/spec/"
end

require "batch_processor"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
  end
end
