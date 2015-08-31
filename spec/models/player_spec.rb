require 'rails_helper'
require_relative 'shared_examples'

RSpec.describe Player, type: :model do
  let(:user)     { User.create!(email: "flipper") }
  let(:game)     { Game.create! }

  let(:player) { user.players.create!(game: game) }
  let(:card)   { Deck::PLATONIC.first }

  context "when interacting with the game" do
    context "picking up" do
      subject { player.pickup!(card) }

      it "adds to player pickups" do
        expect { subject }.to change { player.pickups.count }.by(1)
      end

      it "does not change player plays" do
        expect { subject }.not_to change { player.plays.count }
      end
    end

    context "playing" do
      subject{ player.play!(card) }

      it "adds to player plays" do
        expect { subject }.to change { player.plays.count }.by(1)
      end

      it "to not change player pickups" do
        expect { subject }.not_to change { player.pickups.count }
      end
    end

    context "setting readyness" do
      it "defaults to not ready" do
        expect(player.ready).to be false
        expect(player.ready?).to be false
      end

      it "sets #ready? when ready" do
        player.ready = true
        expect(player.ready?).to be true
      end
    end

  end
end
