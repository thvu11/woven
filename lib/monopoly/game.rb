# frozen_string_literal: true

module Monopoly
  class Game
    PLAYER_NAMES = %w[Peter Billy Charlotte Sweedal].freeze
    START_MONEY  = 16
    GO_BONUS     = 1

    Result = Struct.new(:bankrupt_player, :winners, :players, keyword_init: true) do
      def finished?
        !bankrupt_player.nil?
      end
    end

    def initialize(board:, rolls:, player_names: PLAYER_NAMES)
      @board   = board
      @rolls   = rolls
      @players = player_names.map { |name| Player.new(name, money: START_MONEY) }
    end

    def play
      bankrupt_player = nil

      @rolls.each_with_index do |roll, turn|
        player = @players[turn % @players.size]
        take_turn(player, roll)

        if player.bankrupt?
          bankrupt_player = player
          break
        end
      end

      return build_result(bankrupt_player)
    end

    private

    def take_turn(player, roll)
      laps, player.position = (player.position + roll).divmod(@board.size)
      player.receive(GO_BONUS * laps) # $1 per pass of GO (landing on GO counts)

      cell = @board.cell_at(player.position)
      land(player, cell) if cell.property?
    end

    def land(player, property)
      if !property.owned?
        buy(player, property)
      elsif property.owner != player
        pay_rent(player, property)
      end
      # Landing on your own property: nothing happens.
    end

    def buy(player, property)
      player.pay(property.price)
      property.owner = player
    end

    # The owner receives the full rent even if it bankrupts the payer.
    def pay_rent(player, property)
      rent = property.price
      rent *= 2 if @board.monopoly?(property.colour, property.owner)

      player.pay(rent)
      property.owner.receive(rent)
    end

    def build_result(bankrupt_player)
      winners = []
      # assumption: can have multiple winners i.e multiple players have an equal amount of money when we find a loser
      if bankrupt_player
        top = @players.map(&:money).max
        winners = @players.select { |p| p.money == top }
      end

      return Result.new(bankrupt_player: bankrupt_player, winners: winners, players: @players)
    end
  end
end
