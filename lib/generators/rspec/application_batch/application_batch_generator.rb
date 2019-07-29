# frozen_string_literal: true

module Rspec
  module Generators
    class ApplicationBatchGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_spec_file
        template "application_batch_spec.rb", File.join("spec/batches/application_batch_spec.rb")
      end
    end
  end
end

