# frozen_string_literal: true

RSpec.describe BatchProcessor::Processors::Sequential, type: :processor do
  subject { described_class }

  it { is_expected.to inherit_from BatchProcessor::ProcessorBase }

  describe ".disable_retries?" do
    subject { described_class.disable_retries? }

    it { is_expected.to eq true }
  end

  describe "#process_collection_item" do
    include_context "with an example processor batch"

    subject(:execute) { described_class.execute(batch: example_batch, **options) }

    let(:options) { {} }

    before { allow(example_batch).to receive(:job_class).and_return(job_class) }

    shared_examples_for "the batch is processed" do
      it "processes the batch" do
        execute

        collection_items.each do |item|
          expect(job_class).to have_received(:new).with(item).ordered
          expect(collection_instances[item].batch_id).to eq example_batch.batch_id
          expect(collection_instances[item]).to have_received(:perform_now).ordered
        end
      end
    end

    context "with error" do
      let(:options) { Hash[:continue_after_exception, continue_after_exception] }

      before { allow(collection_instances[collection_items[1]]).to receive(:perform_now).and_raise(RuntimeError) }

      context "when #continue_after_exception" do
        let(:continue_after_exception) { true }

        it_behaves_like "the batch is processed"
      end

      context "when not #continue_after_exception" do
        let(:continue_after_exception) { false }

        it "raises" do
          expect { execute }.to raise_error RuntimeError

          expect(job_class).to have_received(:new).with(collection_items[0]).ordered
          expect(job_class).to have_received(:new).with(collection_items[1]).ordered
          expect(job_class).not_to have_received(:new).with(collection_items[2])
        end
      end
    end

    context "without error" do
      before { allow(job_class).to receive(:perform_now) }

      it_behaves_like "the batch is processed"
    end
  end

  describe "#iterator_method" do
    include_context "with an example batch"

    subject { described_class.new(batch: example_batch, sorted: sorted).__send__(:iterator_method) }

    let(:collection_items) { double(find_each: nil) }

    before do
      allow(example_batch).to receive(:collection_items).and_return(collection_items)
      allow(collection_items).to receive(:find_each)
    end

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
