# frozen_string_literal: true

RSpec.describe BatchProcessor::Malfunction::CollectionInvalid, type: :malfunction do
  include_context "with an example batch"

  subject(:malfunction) { described_class.new(example_batch.collection) }

  it { is_expected.to inherit_from BatchProcessor::Malfunction::Base }

  it { is_expected.to have_prototype_name "CollectionInvalid" }
  it { is_expected.to conjugate_into BatchProcessor::CollectionInvalidError }

  it { is_expected.to use_attribute_errors }
  it { is_expected.to contextualize_as :collection }

  it { is_expected.to delegate_method(:errors).to(:collection).with_prefix }

  describe "#build" do
    subject(:_build) { malfunction.build }

    let(:input) { Hash[:foo, 0.1] }

    let(:expected_attribute_errors) { [ foo_numericality_error, bar_presence_error ] }
    let(:foo_numericality_error) do
      Malfunction::AttributeError.new(attribute_name: :foo, error_code: :not_an_integer, message: "must be an integer")
    end
    let(:bar_presence_error) do
      Malfunction::AttributeError.new(attribute_name: :bar, error_code: :blank, message: "can't be blank")
    end

    before do
      example_batch_class::Collection.tap do |klass|
        klass.__send__(:argument, :foo)
        klass.__send__(:option, :bar)

        klass.validates :foo, numericality: { only_integer: true }
        klass.validates :bar, presence: true
      end

      example_batch.collection.valid?
    end

    it "sets attribute errors" do
      expect { _build }.to change { malfunction.attribute_errors }.to(array_including(*expected_attribute_errors))
    end
  end
end
