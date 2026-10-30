# frozen_string_literal: true

module Monopoly
  # Any non-buyable cell (currently just GO i.e the starting position).
  Space = Struct.new(:name, :type, keyword_init: true) do
    def property?
      return false
    end
  end
end
