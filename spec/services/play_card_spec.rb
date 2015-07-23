require 'rails_helper'
require_relative 'shared_examples'

RSpec.describe PlayCard do
  let(:player1) { Player.create!(nickname: "megatron") }
  let(:player2) { Player.create!(nickname: "optimus") }
  let(:game)    { Game.create! }

  def round
    Round.new(game)
  end

  def hand
    round.hands[player1.nickname]
  end

  let(:good_card) { hand.first }
  let(:top_card)  { round.pile.last }
  let(:bad_suits) { Card::SUITS - [top_card.suit] }
  let(:bad_ranks) { Card::RANKS - [top_card.rank] }
  let(:bad_card)  { Card.find_by(rank: bad_ranks.last, suit: bad_suits) }

  let(:card)    { Card.first }
  let(:service) { PlayCard.new(player1, round, card) }

  context "before the game has started" do
    it_behaves_like "a service with errors"
  end

  context "when game is over" # TODO

  context "after the game has started" do
    before do
      game.players << player1
      game.players << player2
      game.save!
      StartGame.new(game).call or fail "untestable"
    end

    context "playing a card with wrong rank and suit" do
      let(:card) { bad_card }
      it_behaves_like "a service with errors"
    end

    context "playing a card of the same rank" # TODO

    context "playing a card of the same suit" # TODO
  end

  # TODO game over
end