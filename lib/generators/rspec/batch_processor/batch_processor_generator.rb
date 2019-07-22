# frozen_string_literal: true

module Rspec
  module Generators
    class BatchProcessorGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_spec_file
        template "batch_spec.rb.erb", File.join("spec/batches/", class_path, "#{file_name}_batch_spec.rb")
      end
    end
  end
end
