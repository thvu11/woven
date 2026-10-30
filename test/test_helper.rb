# frozen_string_literal: true

require "minitest/autorun"
require "monopoly"

module BoardHelpers
  def go_cell(name = "GO")
    { "name" => name, "type" => "go" }
  end

  def property_cell(name, price, colour)
    { "name" => name, "price" => price, "colour" => colour, "type" => "property" }
  end

  def build_board(*cells)
    Monopoly::Board.new(cells)
  end

  # GO, A(1,Brown), B(1,Brown), C(2,Blue), D(2,Blue)  => size 5
  def small_board
    build_board(
      go_cell,
      property_cell("A", 1, "Brown"),
      property_cell("B", 1, "Brown"),
      property_cell("C", 2, "Blue"),
      property_cell("D", 2, "Blue")
    )
  end

  def play(board, rolls, players: %w[Peter Billy])
    Monopoly::Game.new(board: board, rolls: rolls, player_names: players).play
  end

  def player_named(result, name)
    result.players.find { |p| p.name == name }
  end
end

class Minitest::Test
  include BoardHelpers
end
