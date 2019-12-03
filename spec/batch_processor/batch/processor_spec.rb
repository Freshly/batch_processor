# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Processor, type: :module do
  include_context "with an example batch"

  it { is_expected.to delegate_method(:processor_class).to(:class) }
  it { is_expected.to delegate_method(:processor_options).to(:class) }

  shared_examples_for "a processor strategy resolver" do |strategy|
    subject(:resolver) { example_batch_class.__send__("with_#{strategy}_processor".to_sym) }

    it "assigns class" do
      expect { resolver }.
        to change { example_batch_class.instance_variable_get(:@processor_class) }.
        from(nil).
        to(described_class::PROCESSOR_CLASS_BY_STRATEGY[strategy])
    end
  end

  describe ".with_sequential_processor" do
    it_behaves_like "a processor strategy resolver", :sequential
  end

  describe ".with_parallel_processor" do
    it_behaves_like "a processor strategy resolver", :parallel
  end

  describe ".processor_class" do
    subject(:processor_class) { example_batch_class.processor_class }

    context "with @processor_class" do
      before { example_batch_class.__send__(:with_sequential_processor) }

      it { is_expected.to eq described_class::PROCESSOR_CLASS_BY_STRATEGY[:sequential] }
    end

    context "without @processor_class" do
      it { is_expected.to eq described_class::PROCESSOR_CLASS_BY_STRATEGY[:default] }
    end
  end

  describe ".processor_option" do
    subject(:processor_option) { example_batch_class.__send__(:processor_option, option, value) }

    let(:option) { Faker::Internet.domain_word.to_sym }
    let(:value) { SecureRandom.hex }

    shared_examples_for "option is set" do
      let(:expected) { existing.merge(option => value) }

      before { example_batch_class._processor_options.merge! existing }

      it "sets option" do
        expect { processor_option }.to change { example_batch_class._processor_options }.from(existing).to(expected)
      end
    end

    context "with existing options" do
      let(:existing) { Hash[*Faker::Lorem.words(2 * rand(1..2))] }

      it_behaves_like "option is set"
    end

    context "without existing options" do
      let(:existing) { {} }

      it_behaves_like "option is set"
    end
  end

  describe ".inherited" do
    it_behaves_like "an inherited property", :processor_option do
      let(:root_class) { example_batch_class }
      let(:expected_attribute_value) do
        expected_property_value.each_with_object({}) do |argument, hash|
          hash[argument] = nil
        end
      end
    end
  end

  describe "#process" do
    subject(:process) { example_batch.process }

    context "with error" do
      before do
        allow(example_batch).to receive(:process!).and_raise error_class
        allow(example_batch).to receive(:error).and_call_original
      end

      shared_examples_for "the expected malfunction is set" do
        it "has expected malfunction" do
          expect { process }.to change { example_batch.malfunction }.to(an_instance_of(expected_malfunction_class))
        end
      end

      shared_examples_for "no malfunction is set" do
        it "doesn't have a malfunction" do
          expect { process }.not_to change { example_batch.malfunction }.from(nil)
        end
      end

      context "when StandardError" do
        let(:error_class) { StandardError }

        it "raises" do
          expect { process }.to raise_error error_class
        end
      end

      context "when basic BatchProcessor::Error" do
        let(:error_class) { BatchProcessor::Error }

        it "calls logs the exception without raising" do
          process
          expect(example_batch).to have_received(:error).with(:process_error, exception: instance_of(error_class))
        end

        it { is_expected.to eq example_batch }

        it_behaves_like "no malfunction is set"
      end

      context "when BatchProcessor::CollectionInvalidError" do
        let(:error_class) { BatchProcessor::CollectionInvalidError }

        it "calls logs the exception without raising" do
          expect { process }.
            to change { example_batch.malfunction }.to(an_instance_of(BatchProcessor::Malfunction::CollectionInvalid)).
            and change { example_batch.malfunction&.collection }.to(example_batch.collection)
        end
      end

      context "when BatchProcessor::CollectionEmptyError" do
        let(:error_class) { BatchProcessor::CollectionEmptyError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::CollectionEmpty }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::AlreadyAbortedError" do
        let(:error_class) { BatchProcessor::AlreadyAbortedError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::AlreadyAborted }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::AlreadyClearedError" do
        let(:error_class) { BatchProcessor::AlreadyClearedError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::AlreadyCleared }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::AlreadyEnqueuedError" do
        let(:error_class) { BatchProcessor::AlreadyEnqueuedError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::AlreadyEnqueued }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::AlreadyFinishedError" do
        let(:error_class) { BatchProcessor::AlreadyFinishedError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::AlreadyFinished }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::AlreadyStartedError" do
        let(:error_class) { BatchProcessor::AlreadyStartedError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::AlreadyStarted }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::NotAbortedError" do
        let(:error_class) { BatchProcessor::NotAbortedError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::NotAborted }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::NotProcessingError" do
        let(:error_class) { BatchProcessor::NotProcessingError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::NotProcessing }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::NotStartedError" do
        let(:error_class) { BatchProcessor::NotStartedError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::NotStarted }

        it_behaves_like "the expected malfunction is set"
      end

      context "when BatchProcessor::StillProcessingError" do
        let(:error_class) { BatchProcessor::StillProcessingError }
        let(:expected_malfunction_class) { BatchProcessor::Malfunction::StillProcessing }

        it_behaves_like "the expected malfunction is set"
      end
    end

    context "without error" do
      before { allow(example_batch).to receive(:process!).and_return result }

      let(:result) { double }

      it { is_expected.to eq result }
    end
  end

  describe ".process" do
    it_behaves_like "a class pass method", :process do
      let(:test_class) { example_batch_class }
      let(:call_class) { example_batch_class }
    end
  end

  describe "#process!" do
    subject(:process!) { example_batch.process! }

    let(:processor_class) { double }
    let(:processor_options) { Hash[*Faker::Lorem.words(2 * rand(1..2))].symbolize_keys }

    before do
      allow(example_batch).to receive(:processor_class).and_return(processor_class)
      allow(example_batch).to receive(:_processor_options).and_return(processor_options)
      allow(processor_class).to receive(:execute)
    end

    it "executes the processor" do
      process!
      expect(processor_class).to have_received(:execute).with(batch: example_batch, **processor_options)
    end

    it { is_expected.to be_an_instance_of example_batch_class }
  end

  describe ".process!" do
    it_behaves_like "a class pass method", :process do
      let(:test_class) { example_batch_class }
      let(:call_class) { example_batch_class }
    end
  end
end
