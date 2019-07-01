# frozen_string_literal: true

module BatchProcessor
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def run_other_generators
        generate "batch_processor:application_batch"
        generate "batch_processor:application_job"
      end
    end
  end
end
