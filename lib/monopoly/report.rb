# frozen_string_literal: true
require 'json'

module Monopoly
  module Report
    def self.format(result, board)
      lines = []

      if result.finished?
        names = result.winners.map(&:name).join(", ")
        lines << "#{result.bankrupt_player.name} went bankrupt."
        lines << "Winner: #{names}#{' (tie)' if result.winners.size > 1}"
      else
        lines << "Rolls ran out before anyone went bankrupt. No winner."
      end

      result.players.sort{ |a,b| b.money <=> a.money }.each do |player|
        space = board.cell_at(player.position).name
        lines << "  #{player.name}: $#{player.money}, finished on #{space}"
      end

      return lines.join("\n")
    end

    def self.json_format(result, board)
      players = []
      result.players.sort{ |a,b| b.money <=> a.money }.each do |player|
        item = {
          :name => player.name,
          :money => player.money,
          :space => board.cell_at(player.position).name
        }
        players.push(item)
      end
      content = {
        :winner => result.winners.map(&:name).join(", "),
        :players => players
      }
      return JSON.pretty_generate(content)
    end
  end
end
