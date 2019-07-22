# frozen_string_literal: true

module BatchProcessor
  module Generators
    class BatchProcessorGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      hook_for :test_framework

      def create_application_flow
        template "batch.rb.erb", File.join("app/batches/", class_path, "#{file_name}_batch.rb")
      end
    end
  end
end
