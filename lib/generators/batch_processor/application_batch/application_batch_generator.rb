# frozen_string_literal: true

module BatchProcessor
  module Generators
    class ApplicationBatchGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      hook_for :test_framework

      def create_application_batch
        template "application_batch.rb", File.join("app/batches/application_batch.rb")
      end
    end
  end
end
