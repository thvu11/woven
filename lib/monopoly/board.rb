# frozen_string_literal: true

module Monopoly
  class Board
    def initialize(cells_data)
      @cells = cells_data.map { |data| build_cell(data) }
      @colour_groups = @cells.select(&:property?).group_by(&:colour)
    end

    def size
      return @cells.size
    end

    # Index wraps around, so any non-negative integer is safe.
    def cell_at(index)
      return @cells[index % size]
    end

    def colour_group(colour)
      return @colour_groups.fetch(colour, [])
    end

    # True when `owner` holds every property of the given colour.
    def monopoly?(colour, owner)
      return colour_group(colour).all? { |property| property.owner == owner }
    end

    private

    def build_cell(data)
      case data["type"]
      when "property"
        Property.new(name: data["name"], price: data["price"], colour: data["colour"])
      when "go"
        Space.new(name: data["name"], type: :go)
      else
        raise ArgumentError, "unknown cell type: #{data['type'].inspect}"
      end
    end
  end
end
