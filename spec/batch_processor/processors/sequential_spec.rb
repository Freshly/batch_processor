# frozen_string_literal: true

RSpec.describe BatchProcessor::Processors::Sequential, type: :processor do
  include_context "with an example batch"

  subject { described_class }

  let(:collection) do
    Array.new(3) { Hash[*Faker::Lorem.words(2)] }
  end
  let(:job_class) { Class.new(BatchProcessor::BatchJob) }

  before do
    allow(example_batch).to receive(:collection).and_return(collection)
    allow(example_batch).to receive(:job_class).and_return(job_class)
  end

  it { is_expected.to inherit_from BatchProcessor::ProcessorBase }

  describe "#process_collection_item" do
    subject(:execute) { described_class.execute(batch: example_batch, **options) }

    let(:options) { {} }

    before { allow(example_batch).to receive(:job_class).and_return(job_class) }

    shared_examples_for "the batch is processed" do
      it "processes the batch" do
        execute
        collection.each { |item| expect(job_class).to have_received(:perform_now).with(item).ordered }
      end
    end

    context "with error" do
      let(:options) { Hash[:continue_after_exception, continue_after_exception] }

      before do
        allow(job_class).to(receive(:perform_now)) { |args| raise RuntimeError, "oops" if args == collection[1] }
      end

      context "when #continue_after_exception" do
        let(:continue_after_exception) { true }

        it_behaves_like "the batch is processed"
      end

      context "when not #continue_after_exception" do
        let(:continue_after_exception) { false }

        it "raises" do
          expect { execute }.to raise_error RuntimeError, "oops"
          expect(job_class).to have_received(:perform_now).with(collection[0]).ordered
          expect(job_class).to have_received(:perform_now).with(collection[1]).ordered
          expect(job_class).not_to have_received(:perform_now).with(collection[2])
        end
      end
    end

    context "without error" do
      before { allow(job_class).to receive(:perform_now) }

      it_behaves_like "the batch is processed"
    end
  end

  describe "#iterator_method" do
    subject { described_class.new(batch: example_batch, sorted: sorted).__send__(:iterator_method) }

    let(:collection) { double(find_each: nil) }

    before { allow(collection).to receive(:find_each) }

    context "when sorted" do
      let(:sorted) { true }

      it { is_expected.to eq :each }
    end

    context "when not sorted" do
      let(:sorted) { false }

      it { is_expected.to eq :find_each }
    end
  end
end
