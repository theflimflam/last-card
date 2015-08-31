require 'rails_helper'

RSpec.describe Round do
  # predictable seed for predictable shuffles
  before { srand 1 }

  let(:player) { game.players.first }
  let(:game)   { Game.create! }

  before do
    game.users.create!(email: "tintin")
    game.users.create!(email: "snowy")
  end

  def round
    Round.new(game)
  end

  def hand
    round.hands[player.id]
  end

  context "before game start" do
    it "has a full deck of cards" do
      expect(round.deck.size).to be 52
    end

    it "has no allocation to hands" do
      card_count = round.hands.values.map(&:count).sum
      expect(card_count).to be 0
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

      subject { player.pickup!(card) }

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
        before { player.pickup!(card) }

        it "removed picked up card from deck" do
          expect(round.deck).to_not include card
        end

        it "added the pickup to player's hand" do
          expect(hand).to include card
        end
      end
    end

    context "when card is played" do
      # card now comes from a player's hand
      let(:card) { hand.first }

      subject { player.play!(card) }

      it "removes cards from player's hand" do
        expect { subject }.to change { round.hands[player.id].size }.by(-1)
      end

      it "only removes from one of the player's hands" do
        expect { subject }.to change { round.hands.values.flatten.size }.by(-1)
      end

      it "adds cards to the pile" do
        expect { subject }.to change { round.pile.size }.by(+1)
      end

      it "does not change the deck" do
        expect { subject }.to_not change { round.deck.size }
      end

      context "after action" do
        before { player.play!(card) }

        it "removed card from player's hand" do
          expect(hand).to_not include card
        end

        it "contains the card in the pile" do
          expect(round.pile).to include card
        end

        it "put the card on the top of the pile" do
          expect(round.pile.top).to eq card
        end
      end
    end

    context "after shuffle" do
      let(:last_played_card)          {  hand.first }
      let(:second_to_last_played_card) { hand.last }

      before do
        player.play!(second_to_last_played_card)
        player.play!(last_played_card)
        player.shuffle!
      end

      describe "the pile" do
        it "gets emptied of all but 1 card" do
          expect(round.pile.size).to eq 1
        end

        it "keeps the last card played on the top" do
          expect(round.pile.top).to eq last_played_card
        end
      end

      describe "the deck" do
        it "now has cards" do
          expect(round.deck).to_not be_empty
        end

        it "contains the first card played by the dealer" do
          expect(round.deck).to include second_to_last_played_card
        end
      end

      context "the next play" do
        let(:played_card_after_shuffle) { hand.last }

        before { player.play!(played_card_after_shuffle) }

        describe "the pile" do
          it "has 2 cards" do
            expect(round.pile.size).to be 2
          end

          it "still has the last play from before shuffle" do
            expect(round.pile).to include last_played_card
          end

          it "now shows the played card on top of the pile" do
            expect(round.pile.top).to eq played_card_after_shuffle
          end

          it "does not contain the card just played" do
            expect(round.deck).to_not include played_card_after_shuffle
          end
        end
      end

      context "when cards have come arond more than once" do
        it "can still be used in a players hand" do
          expect { player.pickup!(second_to_last_played_card) }
            .to change { hand }
            .to include second_to_last_played_card
        end
      end
    end
  end

  context "when the game ends" # TODO
end
