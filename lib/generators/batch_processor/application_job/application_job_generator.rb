# frozen_string_literal: true

module BatchProcessor
  module Generators
    class ApplicationJobGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      hook_for :test_framework

      def create_application_job
        template "application_job.rb", File.join("app/jobs/application_job.rb")
      end
    end
  end
end
