# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Processor, type: :module do
  include_context "with an example batch", described_class

  it { is_expected.to delegate_method(:processor_class).to(:class) }

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
    subject(:processor_class) { example_batch_class.__send__(:processor_class) }

    context "with @processor_class" do
      before { example_batch_class.__send__(:with_sequential_processor) }

      it { is_expected.to eq described_class::PROCESSOR_CLASS_BY_STRATEGY[:sequential] }
    end

    context "without @processor_class" do
      it { is_expected.to eq described_class::PROCESSOR_CLASS_BY_STRATEGY[:default] }
    end
  end
end
