require 'rails_helper'

RSpec.describe Round do
  # predictable seed for predictable shuffles
  before { srand 1 }

  let(:player) { game.players.first }
  let(:game) { Game.create! }

  before do
    game.players.create!(nickname: "tintin")
    game.players.create!(nickname: "snowy")
  end

  def round
    Round.new(game)
  end

  def hand
    round.hands[player.nickname]
  end

  context "before game start" do
    it "has a full deck of cards" do
      expect(round.deck.size).to be 52
    end

    it "has no allocation to hands" do
      expect(round.hands).to be_empty
    end

    it "has no discard" do
      expect(round.pile).to be_empty
    end
  end

  context "in play" do
    before { StartGame.new(game).call or fail "untestable" }

    context "when game starts" do
      it "gives each player 5 cards" do
        round.hands.values.each do |hand|
          expect(hand.size).to be 5
        end
      end

      it "puts a card on the pile" do
        expect(round.pile.size).to be 1
      end
    end

    context "when player picks up" do
      let(:card) { round.deck.first }

      subject { player.pickup!(game,card) }

      it "does not change pile" do
        expect { subject }.to_not change { round.pile.size }
      end

      it "removes cards from the deck" do
        expect { subject }.to change { round.deck.size }.by(-1)
      end

      it "adds cards to player's hand" do
        expect { subject }.to change { round.hands.values.flatten.size }.by(1)
      end

      context "after action" do
        before { player.pickup!(game,card) }

        it "removed picked up card from deck" do
          expect(round.deck).to_not include card
        end

        it "added the pickup to players hand" do
          expect(hand).to include card
        end
      end
    end

    context "when card is played" do
      # card now comes from a players hand
      let(:card) { hand.first }

      subject { player.play!(game ,card) }

      it "removes cards from player's hand" do
        expect { subject }.to change { round.hands[player.nickname].size }.by(-1)
      end

      it "only removes from one of the players hands" do
        expect { subject }.to change { round.hands.values.flatten.size }.by(-1)
      end

      # TODO PlayCard.new(round, Oplayer, card).call
      it "adds cards to the pile" do
        expect { subject }.to change { round.pile.size }.by(+1)
      end

      it "does not change the deck" do
        expect { subject }.to_not change { round.deck.size }
      end

      context "after action" do
        before { player.play!(game,card) }

        it "removed card from players hand" do
          expect(hand).to_not include card
        end

        it "contains the card in the pile" do
          expect(round.pile).to include card
        end

        it "put the card on the top of the pile" do
          expect(round.pile.last).to eq card
        end
      end
    end

    context "when deck is ready for reshuffle" do
      let(:top_card)    { hand.first }
      let(:last_round)  { round }

      before do
        # Player plays a card
        player.play!(game, top_card)

        # Player picks up all cards
        last_round.deck.each do |card|
          player.pickup!(game, card)
        end
      end

      describe "the pile" do
        it "gets emptied of all but 1 card" do
          expect(round.pile.size).to be 1
        end

        it "keeps the last card played on the top" do
          expect(round.pile.last).to eq last_round.pile.last
        end
      end

      describe "the deck" do
        it "shuffles in cards from the pile" do
          expect(round.deck.size).to be 1
        end

        it "contains the first card played by the dealer" do
          expect(round.deck).to include last_round.pile.first
        end
      end

      context "the next play" do
        let(:next_played_card) { hand.last }

        before { player.play!(game, next_played_card) }

        describe "the pile" do
          it "has 2 cards" do
            expect(round.pile.size).to be 2
          end

          it "still has the last play from before shuffle" do
            expect(round.pile.first).to eq last_round.pile.last
          end

          it "now shows the played card on top of the pile" do
            expect(round.pile.last).to eq next_played_card
          end
        end

        describe "the deck" do
          it "still only has cards from previous pile" do
            expect(round.deck.size).to be 1
          end

          it "contains the first card played by the dealer" do
            expect(round.deck).to include last_round.pile.first
          end

          it "does not contain the card just played" do
            expect(round.deck).to_not include next_played_card
          end
        end
      end
    end
  end

  context "when the game ends" do
    # TODO flesh out examples
  end
end