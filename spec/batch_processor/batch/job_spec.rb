# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Job, type: :module do
  include_context "with an example batch"

  let(:batchable_job_class) { Class.new(BatchProcessor::BatchJob) }

  it { is_expected.to delegate_method(:job_class).to(:class) }

  describe ".process_with_job" do
    subject(:process_with_job) { example_batch_class.__send__(:process_with_job, job_class) }

    context "when unbatchable" do
      let(:job_class) { Class.new }

      it "raises" do
        expect { process_with_job }.to raise_error ArgumentError, "Unbatchable job"
      end
    end

    context "when batchable" do
      let(:job_class) { batchable_job_class }

      it "sets @job_class" do
        expect { process_with_job }.
          to change { example_batch_class.instance_variable_get(:@job_class) }.
          from(nil).
          to(job_class)
      end
    end
  end

  describe ".job_class" do
    subject(:job_class) { example_batch_class.job_class }

    let(:example_job_class) { batchable_job_class }

    context "with @job_class" do
      before { example_batch_class.__send__(:process_with_job, example_job_class) }

      it { is_expected.to eq example_job_class }
    end

    context "without @job_class" do
      let(:example_job_class_name) { "#{root_name}Job" }

      before { stub_const(example_job_class_name, example_job_class) }

      it { is_expected.to eq example_job_class }
    end
  end
end
