# frozen_string_literal: true

RSpec.describe BatchProcessor::Batch::Worker, type: :module do
  include_context "with an example batch", described_class

  it { is_expected.to delegate_method(:worker_class).to(:class) }

  describe ".process_with" do
    subject(:process_with) { example_batch_class.__send__(:process_with, worker_class) }

    context "with a non-class" do
      let(:worker_class) { :worker_class }

      it "raises" do
        expect { process_with }.to raise_error TypeError, "worker_class must be a Class"
      end
    end

    context "with a class" do
      context "without #perform_now" do
        let(:worker_class) { Class.new }

        it "raises" do
          expect { process_with }.to raise_error ArgumentError, "worker_class must define .perform_now"
        end
      end

      context "with #perform_now" do
        context "without #perform_later" do
          let(:worker_class) do
            Class.new do
              class << self
                def perform_now; end
              end
            end
          end

          it "raises" do
            expect { process_with }.to raise_error ArgumentError, "worker_class must define .perform_later"
          end
        end

        context "with #perform_later" do
          let(:worker_class) do
            Class.new do
              class << self
                def perform_now; end
                def perform_later; end
              end
            end
          end

          it "sets @worker_class" do
            expect { process_with }.
              to change { example_batch_class.instance_variable_get(:@worker_class) }.
              from(nil).
              to(worker_class)
          end
        end
      end
    end
  end

  describe ".worker_class" do
    subject(:worker_class) { example_batch_class.__send__(:worker_class) }

    let(:example_worker_class) do
      Class.new do
        class << self
          def perform_now; end
          def perform_later; end
        end
      end
    end

    context "with @worker_class" do
      before { example_batch_class.__send__(:process_with, example_worker_class) }

      it { is_expected.to eq example_worker_class }
    end

    context "without worker class" do
      let(:root_name) { Faker::Internet.domain_word.capitalize }
      let(:example_batch_class_name) { "#{root_name}Batch" }
      let(:example_worker_class_name) { "#{root_name}Job" }

      before do
        stub_const(example_batch_class_name, example_batch_class)
        stub_const(example_worker_class_name, example_worker_class)
      end

      it { is_expected.to eq example_worker_class }
    end
  end
end
