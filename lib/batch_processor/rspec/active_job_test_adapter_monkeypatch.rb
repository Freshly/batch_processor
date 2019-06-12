# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    class TestAdapter
      # BatchProcessor relies on serialized arguments being passed to ActiveJob, as the batch_id is put into the
      # serialized hash to keep it out of the arguments and prevent needing a deeper override of ActiveJob's API.
      # This works totally fine and perfect when you are using the test adapter and processing the jobs, as the
      # internal implementation is to just call ActiveJob::Base.execute on the serialized hash. Weirdly, instead of...
      # just putting the serialized hash into an array and using that, the implementation literally reinvents a simpler
      # wheel WHILE USING THE ACTUAL SERIALIZED HASH ITSELF TO EXTRACT ARGUMENTS. So like... I changed that.
      #
      # There didn't seem to be a value to me to put this implementation in a way which keeps the original API because
      # the actual serialized API itself is so similar, refactoring any test implementation to work with the change
      # should be trivial.
      def job_to_hash(job, extras = {})
        job.serialize.merge!(extras)
      end
    end
  end
end
