# frozen_string_literal: true

require "test_helper"

class GameTest < Minitest::Test
  # --- turn order and movement -------------------------------------------

  def test_players_take_turns_in_fixed_order
    result = play(small_board, [1, 2, 3, 4], players: %w[Peter Billy Charlotte Sweedal])

    assert_equal 1, player_named(result, "Peter").position
    assert_equal 2, player_named(result, "Billy").position
    assert_equal 3, player_named(result, "Charlotte").position
    assert_equal 4, player_named(result, "Sweedal").position
  end

  def test_default_players_are_the_four_named_players
    game = Monopoly::Game.new(board: small_board, rolls: [])
    result = game.play

    assert_equal %w[Peter Billy Charlotte Sweedal], result.players.map(&:name)
    assert(result.players.all? { |p| p.money == 16 && p.position.zero? })
  end

  # --- passing GO --------------------------------------------------------

  def test_starting_move_does_not_pay_go_bonus
    result = play(small_board, [1])

    # 16 - 1 (bought A), no GO bonus
    assert_equal 15, player_named(result, "Peter").money
  end

  def test_landing_exactly_on_go_pays_bonus
    result = play(small_board, [5])
    peter = player_named(result, "Peter")

    assert_equal 0, peter.position
    assert_equal 17, peter.money
  end

  def test_passing_go_pays_bonus
    # Turn 1: pos 4 (D), buy for 2 -> 14
    # Turn 2: 4+3=7 -> pos 2 (B), +1 for GO, buy for 1 -> 14
    result = play(small_board, [4, 3], players: %w[Peter])
    peter = player_named(result, "Peter")

    assert_equal 2, peter.position
    assert_equal 14, peter.money
  end

  def test_multiple_laps_in_one_roll_pay_multiple_bonuses
    # 11 on a 5-cell board: 2 laps, lands on A. 16 + 2 - 1 = 17
    result = play(small_board, [11], players: %w[Peter])

    assert_equal 1, player_named(result, "Peter").position
    assert_equal 17, player_named(result, "Peter").money
  end

  # --- buying ------------------------------------------------------------

  def test_landing_on_unowned_property_buys_it
    board = small_board
    result = play(board, [3])
    peter = player_named(result, "Peter")

    assert_equal 14, peter.money
    assert_same peter, board.cell_at(3).owner
  end

  def test_landing_on_own_property_does_nothing
    # Buy A (15), then 1+5=6 -> lap + back on A: 15 + 1 GO = 16, no rent, no buy
    result = play(small_board, [1, 5], players: %w[Peter])

    assert_equal 16, player_named(result, "Peter").money
    assert_equal 1, player_named(result, "Peter").position
  end

  # --- rent --------------------------------------------------------------

  def test_landing_on_owned_property_pays_rent_to_owner
    # Peter buys A (15); Billy lands on A and pays 1 -> Billy 15, Peter 16
    result = play(small_board, [1, 1])

    assert_equal 16, player_named(result, "Peter").money
    assert_equal 15, player_named(result, "Billy").money
  end

  def test_rent_is_doubled_when_owner_holds_whole_colour
    # Peter buys A (15). Billy buys C (14). Peter buys B (14), owning Brown.
    # Billy: 3+4=7 -> lap, lands on B: 14 + 1 GO - 2 double rent = 13. Peter 14 + 2 = 16.
    result = play(small_board, [1, 3, 1, 4])

    assert_equal 16, player_named(result, "Peter").money
    assert_equal 13, player_named(result, "Billy").money
  end

  # --- bankruptcy and winner ---------------------------------------------

  def test_game_ends_when_purchase_takes_money_below_zero
    board = build_board(go_cell, property_cell("A", 20, "Red"))
    result = play(board, [1, 1, 1])

    assert result.finished?
    assert_equal "Peter", result.bankrupt_player.name
    assert_equal(-4, player_named(result, "Peter").money)
  end

  def test_remaining_rolls_are_ignored_after_bankruptcy
    board = build_board(go_cell, property_cell("A", 20, "Red"))
    result = play(board, [1, 1, 1])
    billy = player_named(result, "Billy")

    assert_equal 16, billy.money
    assert_equal 0, billy.position
  end

  def test_bankruptcy_from_rent_pays_owner_in_full
    board = build_board(
      go_cell,
      property_cell("A", 10, "Brown"),
      property_cell("B", 10, "Brown")
    )
    # Peter buys A (6). Billy buys B (6). Peter lands on B, pays 10 -> -4. Billy 16.
    result = play(board, [1, 2, 1])

    assert result.finished?
    assert_equal "Peter", result.bankrupt_player.name
    assert_equal(-4, player_named(result, "Peter").money)
    assert_equal 16, player_named(result, "Billy").money
    assert_equal ["Billy"], result.winners.map(&:name)
  end

  def test_exactly_zero_money_is_not_bankruptcy
    board = build_board(go_cell, property_cell("A", 16, "Red"))
    result = play(board, [1])

    refute result.finished?
    assert_equal 0, player_named(result, "Peter").money
  end

  def test_winner_is_player_with_most_money
    board = build_board(go_cell, property_cell("A", 20, "Red"))
    result = play(board, [1], players: %w[Peter Billy Charlotte])

    assert_equal %w[Billy Charlotte], result.winners.map(&:name)
  end

  def test_rolls_running_out_gives_no_winner
    result = play(small_board, [1, 2])

    refute result.finished?
    assert_nil result.bankrupt_player
    assert_empty result.winners
  end
end
