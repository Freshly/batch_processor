# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Core, type: :module do
  describe "#initialize" do
    include_context "with example class having callback", :initialize

    let(:id) { SecureRandom.hex }
    let(:input) { Hash[*Faker::Lorem.words(4)].symbolize_keys }
    let(:example_class) { example_class_having_callback.include(described_class) }

    shared_examples_for "an instance" do
      it "stores input" do
        expect(instance.id).to eq id
        expect(instance.input).to eq input
      end
    end

    context "with no arguments" do
      subject(:instance) { example_class.new }

      let(:id) { nil }
      let(:input) { {} }

      it_behaves_like "an instance"
    end

    context "with only an id" do
      subject(:instance) { example_class.new(id) }

      let(:input) { {} }

      it_behaves_like "an instance"
    end

    context "with only input" do
      subject(:instance) { example_class.new(**input) }

      let(:id) { nil }

      it_behaves_like "an instance"
    end

    context "with id and input" do
      subject(:instance) { example_class.new(id, **input) }

      it_behaves_like "an instance"
    end

    it_behaves_like "a class with callback" do
      subject(:callback_runner) { example_class.new }

      let(:example) { example_class }
    end
  end
end
