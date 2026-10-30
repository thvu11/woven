# frozen_string_literal: true

require "test_helper"

class PlayerTest < Minitest::Test
  def setup
    @player = Monopoly::Player.new("Peter", money: 16)
  end

  def test_starts_with_given_money_on_go
    assert_equal "Peter", @player.name
    assert_equal 16, @player.money
    assert_equal 0, @player.position
  end

  def test_receive_adds_money
    @player.receive(3)
    assert_equal 19, @player.money
  end

  def test_pay_subtracts_money
    @player.pay(5)
    assert_equal 11, @player.money
  end

  def test_pay_can_take_money_below_zero
    @player.pay(20)
    assert_equal(-4, @player.money)
  end

  def test_zero_money_is_not_bankrupt
    @player.pay(16)
    refute @player.bankrupt?
  end

  def test_negative_money_is_bankrupt
    @player.pay(17)
    assert @player.bankrupt?
  end
end
