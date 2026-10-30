# frozen_string_literal: true

module Monopoly
  # A buyable cell. Ownership lives here and nowhere else.
  Property = Struct.new(:name, :price, :colour, :owner, keyword_init: true) do
    def property?
      return true
    end

    def owned?
      return !owner.nil?
    end
  end
end
