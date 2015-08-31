require 'rails_helper'
require 'set'
require_relative 'shared_examples'

RSpec.describe PickupCards do
  # predictable seed for predictable shuffles
  before { srand 1 }

  let(:game)     { Game.create! }
  let(:optimus)  { User.create!(email: "optimus") }
  let(:megatron) { User.create!(email: "megatron") }
  let(:player1)  { optimus.players.create!(game: game) }
  let(:player2)  { megatron.players.create!(game: game) }

  let(:number_of_pickups) { 1 }
  let(:service)    { PickupCards.new(player1, round, number_of_pickups) }

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

    it "increments the round" do
      expect { service.call }.to change { game.round_counter }.by 1
    end

    context "when there are no cards in the deck" do
      before do
        round.deck.each do |card|
          player2.pickup!(card)
        end
      end

      it_behaves_like "a service with errors"

      context "and you're asked to pickup 2 cards" do
        let(:number_of_pickups) { 2 }
        before { service.call }

        it "doesn't double up on the errors" do
          expect(service.errors.size).to eq service.errors.uniq.size
        end
      end
    end

    context "picking up 5" do
      subject { service.call }
      let(:number_of_pickups) { 5 }

      # Deck = 2 cards
      # Pile = 2 cards
      context "with a deck of 2 cards" do
        # pickup all but 2 cards
        before do
          round.deck[0...-2].each { |card| player2.pickup!(card) }
        end

        it "is testable" do
          expect(round.deck.size).to be 2
        end

        context "when pile has 1 card" do
          it "is testable" do
            expect(round.pile.size).to be 1
          end

          it "does have errors" do
            expect { subject }.to change { service.errors }
            expect(subject).to be false
          end

          it "only picks up 2 cards" do
            expect { subject }.to change { hand.count }.by 2
          end

          it "does not pick up from the pile" do
            pile_before_shuffle = Set.new(round.pile)
            expect { subject }.to_not change { Set.new(hand).intersect?(pile_before_shuffle) }
          end
        end

        context "when pile has 2 cards" do
          before do
            card = round.hands[player2.id].pop
            player2.play!(card)
          end

          it "is testable" do
            expect(round.pile.size).to be 2
          end

          it "picks up 3 cards total" do
            expect { subject }.to change { hand.count }.by 3
          end

          it "picks up 2 from deck" do
            deck_before_shuffle = Set.new(round.deck)
            expect { subject }
              .to change { Set.new(hand).intersect?(deck_before_shuffle) }
              .to true
          end

          it "picks up 1 from the pile" do
            deck_before_shuffle = Set.new(round.deck)
            expect { subject }
              .to change { Set.new(hand).intersect?(deck_before_shuffle) }
              .to true
          end
        end

        context "when pile is quite big" do
          before do
            # play lots of cards so the pile gets big
            cards = round.hands[player2.id].pop(10)
            cards.each { |card| player2.play!(card) }
          end

          it "is testable" do
            expect(round.pile.size).to be > 5
          end

          it "picks up 5 cards" do
            expect { subject }.to change { player1.pickups.count }.by number_of_pickups
          end


          it "has no errors" do
            expect { subject }.to_not change { service.errors }
            expect(subject).to be true
          end

          it "still picks up 5 cards" do
            expect { subject }.to change { player1.pickups.count }.by number_of_pickups
          end

          it "will create a shuffle action" do
            expect { subject }.to change { game.shuffles.count }.by 1
          end

          it "picks up the last 2 cards from the deck" do
            deck_before_shuffle = Set.new(round.deck)
            expect { subject }
              .to change { Set.new(hand).intersect?(deck_before_shuffle) }
              .to true
          end

          it "picks up 3 from the pile that got shuffled into the deck" do
            pile_before_shuffle = Set.new(round.pile)
            expect { subject }
              .to change { Set.new(hand).intersect?(pile_before_shuffle) }
              .to true
          end
        end
      end
    end
  end
end
