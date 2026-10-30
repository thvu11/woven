# frozen_string_literal: true

module Monopoly
  class Player
    attr_reader :name, :money
    attr_accessor :position

    def initialize(name, money:, position: 0)
      @name     = name
      @money    = money
      @position = position
    end

    def receive(amount)
      @money += amount
    end

    def pay(amount)
      @money -= amount
    end

    # Assumption: bankrupt = money is negative
    def bankrupt?
      return @money.negative?
    end
  end
end
