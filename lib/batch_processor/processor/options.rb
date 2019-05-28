# frozen_string_literal: true

# Options allow fine grained configuration of a processor
module BatchProcessor
  module Processor
    module Options
      extend ActiveSupport::Concern

      included do
        class_attribute :_options, instance_writer: false, default: []

        set_callback(:initialize, :after) do
          unknown = @options.keys - _options.keys
          raise ArgumentError, "unknown processor #{"option".pluralize(unknown.size)}: #{unknown.join(", ")}"
        end
      end

      class_methods do
        def inherited(base)
          base._options = _options.dup
          super
        end

        private

        def option(option, default: nil, &block)
          _options << option
          define_default option, static: default, &block
        end
      end
    end
  end
end
