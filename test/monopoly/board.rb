# frozen_string_literal: true

require "test_helper"

class BoardTest < Minitest::Test
  def test_size
    assert_equal 5, small_board.size
  end

  def test_cell_at_returns_cells_in_order
    board = small_board
    assert_equal "GO", board.cell_at(0).name
    assert_equal "A", board.cell_at(1).name
    assert_equal "D", board.cell_at(4).name
  end

  def test_cell_at_wraps_around
    board = small_board
    assert_equal "GO", board.cell_at(5).name
    assert_equal "B", board.cell_at(7).name
  end

  def test_go_is_not_a_property
    refute small_board.cell_at(0).property?
  end

  def test_properties_are_properties
    assert small_board.cell_at(1).property?
  end

  def test_colour_group_returns_all_properties_of_colour
    names = small_board.colour_group("Brown").map(&:name)
    assert_equal %w[A B], names
  end

  def test_colour_group_for_unknown_colour_is_empty
    assert_empty small_board.colour_group("Pink")
  end

  def test_monopoly_true_when_owner_holds_whole_colour
    board = small_board
    owner = Monopoly::Player.new("Peter", money: 16)
    board.colour_group("Brown").each { |p| p.owner = owner }

    assert board.monopoly?("Brown", owner)
  end

  def test_monopoly_false_when_colour_is_split
    board = small_board
    peter = Monopoly::Player.new("Peter", money: 16)
    billy = Monopoly::Player.new("Billy", money: 16)
    board.cell_at(1).owner = peter
    board.cell_at(2).owner = billy

    refute board.monopoly?("Brown", peter)
  end

  def test_monopoly_false_when_some_unowned
    board = small_board
    peter = Monopoly::Player.new("Peter", money: 16)
    board.cell_at(1).owner = peter

    refute board.monopoly?("Brown", peter)
  end

  def test_each_board_gets_its_own_properties
    data = [go_cell, property_cell("A", 1, "Brown")]
    first  = Monopoly::Board.new(data)
    second = Monopoly::Board.new(data)
    first.cell_at(1).owner = Monopoly::Player.new("Peter", money: 16)

    assert_nil second.cell_at(1).owner
  end

  def test_unknown_cell_type_raises
    bad = { "name" => "Jail", "type" => "jail" }
    assert_raises(ArgumentError) { Monopoly::Board.new([bad]) }
  end
end
