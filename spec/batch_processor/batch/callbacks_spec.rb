# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Callbacks, type: :module do
  subject(:example_class) { Class.new.include described_class }

  it { is_expected.to include_module ActiveSupport::Callbacks }

  it_behaves_like "an example class with callbacks", described_class, %i[
    job_started
    job_retried
    job_performed
    job_canceled
    batch_started
    batch_enqueued
    batch_aborted
    batch_finished
    batch_success
    batch_errored
    batch_completed
  ]

  shared_examples_for "a handler for the callback" do |callback, method = "on_#{callback}".to_sym|
    subject(:run) { instance.run_callbacks(callback) }

    let(:instance) { test_class.new }
    let(:test_class) do
      Class.new(example_class).tap do |klass|
        klass.attr_accessor(:event_hook_run)
        klass.public_send(method) { self.event_hook_run = true }
      end
    end

    it "runs callback" do
      expect { run }.to change { instance.event_hook_run }.from(nil).to(true)
    end
  end

  describe "#on_job_started" do
    it_behaves_like "a handler for the callback", :job_started
  end

  describe "#on_job_retried" do
    it_behaves_like "a handler for the callback", :job_retried
  end

  describe "#on_job_performed" do
    it_behaves_like "a handler for the callback", :job_performed
  end

  describe "#on_job_canceled" do
    it_behaves_like "a handler for the callback", :job_canceled
  end

  describe "#on_batch_started" do
    it_behaves_like "a handler for the callback", :batch_started
  end

  describe "#on_batch_enqueued" do
    it_behaves_like "a handler for the callback", :batch_enqueued
  end

  describe "#on_batch_aborted" do
    it_behaves_like "a handler for the callback", :batch_aborted
  end

  describe "#on_batch_finished" do
    it_behaves_like "a handler for the callback", :batch_finished
  end

  describe "#on_batch_success" do
    it_behaves_like "a handler for the callback", :batch_success
  end

  describe "#on_batch_errored" do
    it_behaves_like "a handler for the callback", :batch_errored
  end

  describe "#on_batch_completed" do
    it_behaves_like "a handler for the callback", :batch_completed
  end
end
