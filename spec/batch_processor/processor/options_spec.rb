# frozen_string_literal: true

RSpec.describe BatchProcessor::Processor::Options, type: :module do
  include_context "with an example processor", described_class

  describe ".define_option" do
    let(:option) { Faker::Internet.domain_word.to_sym }

    shared_examples_for "option is defined" do
      shared_examples_for "option is set" do
        let(:expected) { existing.merge(option => default_value) }

        before { example_processor_class._options.merge! existing }

        it "sets option" do
          expect { define_option }.to change { example_processor_class._options }.from(existing).to(expected)
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

    context "without a given default_value" do
      subject(:define_option) { example_processor_class.__send__(:define_option, option) }

      let(:default_value) { nil }

      it_behaves_like "option is defined"
    end

    context "with a given default_value" do
      subject(:define_option) { example_processor_class.__send__(:define_option, option, default_value: default_value) }

      let(:default_value) { SecureRandom.hex }

      it_behaves_like "option is defined"
    end
  end

  describe ".inherited" do
    it_behaves_like "an inherited property", :define_option, :_options do
      let(:root_class) { example_processor_class }
      let(:expected_attribute_value) do
        expected_property_value.each_with_object({}) do |argument, hash|
          hash[argument] = nil
        end
      end
    end
  end

  describe ".after_initialize" do
    subject(:after_initialize) { example_processor }

    context "with no options" do
      let(:processor_options) { {} }

      it { is_expected.not_to raise_error }
    end

    context "with options" do
      let(:processor_options) { Hash[field0, value0, field1, value1] }

      let(:field0) { Faker::Internet.uniq.domain_word.to_sym }
      let(:field1) { Faker::Internet.uniq.domain_word.to_sym }
      let(:value0) { SecureRandom.hex }
      let(:value1) { SecureRandom.hex }

      context "with unknown options" do
        context "with one unknown" do
          before { example_processor_class.__send__(:define_option, ) }

        end

        context "with several unknown" do

        end
      end

      context "with known options" do
        it { is_expected.not_to raise_error }
      end
    end
  end
end
