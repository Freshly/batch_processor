# frozen_string_literal: true

module BatchProcessor
  module Malfunction
    class CollectionInvalid < Base
      uses_attribute_errors
      contextualize :collection
      delegate :errors, to: :collection, prefix: true

      on_build do
        collection_errors.details.each do |attribute_name, error_details|
          attribute_messages = collection_errors.messages[attribute_name]

          error_details.each_with_index do |error_detail, index|
            add_attribute_error(attribute_name, error_detail[:error], attribute_messages[index])
          end
        end
      end
    end
  end
end
