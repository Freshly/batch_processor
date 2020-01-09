# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "batch_processor/version"

Gem::Specification.new do |spec|
  spec.name          = "batch_processor"
  spec.version       = BatchProcessor::VERSION
  spec.authors       = [ "Eric Garside" ]
  spec.email         = %w[garside@gmail.com]

  spec.summary       = "Write extensible batches for sequential or parallel processing using ActiveJob"
  spec.description   = "Define your collection, job, and callbacks all in one clear and concise object"
  spec.homepage      = "https://github.com/Freshly/batch_processor"
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/{*,.[a-z]*}"]
  spec.require_paths = "lib"

  spec.add_runtime_dependency "activejob", "~> 5.2.1"
  spec.add_runtime_dependency "activesupport", "~> 5.2.1"
  spec.add_runtime_dependency "redis", ">= 3.0"
  
  spec.add_runtime_dependency "spicery", ">= 0.20.4", "< 1.0"
  spec.add_runtime_dependency "malfunction", ">= 0.1.0", "< 1.0"

  spec.add_development_dependency "bundler", "~> 2.0.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "pry-byebug", ">= 3.7.0"
  spec.add_development_dependency "timecop", ">= 0.9.1"
  spec.add_development_dependency "shoulda-matchers", "4.0.1"

  spec.add_development_dependency "rspice", ">= 0.20.4", "< 1.0"
  spec.add_development_dependency "spicerack-styleguide", ">= 0.20.4", "< 1.0"
end
