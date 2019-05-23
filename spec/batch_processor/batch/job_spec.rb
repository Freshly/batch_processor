# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Job, type: :module do
  include_context "with an example batch", described_class

  let(:batchable_job_class) { Class.new(BatchProcessor::BatchableJob) }

  it { is_expected.to delegate_method(:job_class).to(:class) }

  describe ".process_with" do
    subject(:process_with) { example_batch_class.__send__(:process_with, job_class) }

    context "when unbatchable" do
      let(:job_class) { Class.new }

      it "raises" do
        expect { process_with }.to raise_error ArgumentError, "Unbatchable job"
      end
    end

    context "when batchable" do
      let(:job_class) { batchable_job_class }

      it "sets @job_class" do
        expect { process_with }.
          to change { example_batch_class.instance_variable_get(:@job_class) }.
          from(nil).
          to(job_class)
      end
    end
  end

  describe ".job_class" do
    subject(:job_class) { example_batch_class.__send__(:job_class) }

    let(:example_job_class) { batchable_job_class }

    context "with @job_class" do
      before { example_batch_class.__send__(:process_with, example_job_class) }

      it { is_expected.to eq example_job_class }
    end

    context "without worker class" do
      let(:root_name) { Faker::Internet.domain_word.capitalize }
      let(:example_batch_class_name) { "#{root_name}Batch" }
      let(:example_job_class_name) { "#{root_name}Job" }

      before do
        stub_const(example_batch_class_name, example_batch_class)
        stub_const(example_job_class_name, example_job_class)
      end

      it { is_expected.to eq example_job_class }
    end
  end
end
