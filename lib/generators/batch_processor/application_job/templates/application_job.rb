# frozen_string_literal: true

class ApplicationJob < BatchProcessor::BatchJob
  include Technologic
end
