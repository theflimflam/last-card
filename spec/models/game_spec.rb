require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { Game.create! }
  let(:user) { User.create!(email: "batman") }
  let(:player1) { user.players.build }
  let(:player2) { user.players.build }

  # TODO validation against players joining a game twice

  context "when fewer than 2 players" do
    before do
      game.players << player1
      game.save!
    end

    it "is not #ready? to start" do
      expect(game).to_not be_ready
    end
  end

  context "with 2 players" do
    before do
      game.players << player1
      game.players << player2
      game.save!
    end

    it "to be #ready?" do
      expect(game).to be_ready
    end

    context "after game started" do
      before { game.pending = false }

      it "has #started?" do
        expect(game).to be_started
      end

      context "after action" do
        let(:card) { Card.new("queen", "hearts") }

        describe "player#play" do
          subject { player1.play!(card) }

          it "shows up in game#plays" do
            expect { subject }.to change { game.plays.size }.by(1)
          end

          it "doesn't change game#pickups" do
            expect { subject }.to_not change { game.pickups }
          end
        end

        describe "player#pickup" do
          subject { player1.pickup!(card) }

          it "shows up in game#pickups" do
            expect { subject }.to change { game.pickups.size }.by(1)
          end

          it "doesn't change game#plays" do
            expect { subject }.to_not change { game.plays }
          end
        end
      end

      describe "#current_player" do
        it "returns players" do
          expect(game.current_player).to be_instance_of Player
        end
      end
    end
  end
end
