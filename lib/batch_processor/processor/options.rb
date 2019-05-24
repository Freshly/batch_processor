# frozen_string_literal: true

# Options allow fine grained configuration of a processor
module BatchProcessor
  module Processor
    module Options
      extend ActiveSupport::Concern

      included do
        class_attribute :_options, instance_writer: false, default: {}
        delegate :_options, to: :class

        set_callback(:initialize, :after) do
          # TODO: Validate the optiosn are in the whitelist
        end
      end

      class_methods do
        def inherited(base)
          dup = _options.dup
          base._options = dup.each { |k, v| dup[k] = v.dup }
          super
        end

        private

        def define_option(name, default_value: nil)
          _options[name.to_sym] = default_value
        end
      end
    end
  end
end
