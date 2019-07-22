# frozen_string_literal: true

module Rspec
  module Generators
    class ApplicationJobGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_spec_file
        template "application_job_spec.rb", File.join("spec/jobs/application_job_spec.rb")
      end
    end
  end
end

