# frozen_string_literal: true

class FakeOrder < Spicerack::InputObject
  argument :charge_day
  option(:id) { SecureRandom.hex }

  class Collection < Spicerack::InputObject
    argument :array

    delegate_missing_to :array

    def find_each(&block)
      each(&block)
    end
  end

  class << self
    def where(charge_day:)
      FakeOrder::Collection.new array: Array.new((charge_day == :zero) ? 0 : rand(5..9)) { new(charge_day: charge_day) }
    end
  end
end
