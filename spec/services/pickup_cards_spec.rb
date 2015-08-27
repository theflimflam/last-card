require 'rails_helper'
require_relative 'shared_examples'

RSpec.describe PickupCards do
  # predictable seed for predictable shuffles
  before { srand 1 }

  let(:game)     { Game.create! }
  let(:optimus)  { User.create!(email: "optimus") }
  let(:megatron) { User.create!(email: "megatron") }
  let(:player1)  { optimus.players.create!(game: game) }
  let(:player2)  { megatron.players.create!(game: game) }

  let(:card_count) { 1 }
  let(:service)    { PickupCards.new(player1, round, card_count) }

  def round
    Round.new(game)
  end

  def hand
    round.hands[player1.id]
  end

  context "when game is over" # TODO

  context "after the game has started" do
    before do
      game.players << player1
      game.players << player2
      game.save!
      StartGame.new(game).call or fail "untestable"
    end

    it "executes successfully" do
      expect(service.call).to be true
    end

    it "adds cards to the player's hand" do
      expect { service.call }.to change { hand.size }.by(1)
    end

    it "removes cards from the deck" do
      expect { service.call }.to change { round.deck.size }.by(-1)
    end

    it "does not change the pile" do
      expect { service.call }.to_not change { round.pile }
    end

    context "when there are no cards in the deck" do
      before do
        round.deck.each do |card|
          player2.pickup!(card)
        end
      end

      it_behaves_like "a service with errors"
    end

    context "pickup 5" do
      subject { service.call }
      let(:card_count) { 5 }

      it "picks up 5 cards" do
        expect { subject }.to change { player1.pickups.count }.by 5
      end

      #context "with deck of 2 cards" do
      #  it "picks up 2 from deck, 3 from shuffled pile"

      #  context "with a pile of 2 cards" do
      #    it "picks up 2 from deck, 1 from shuffled pile"
      #  end

      #  context "with pile of 1 card" do
      #    it "only picks up 2 cards"
      #  end
      #end
    end
  end
end
