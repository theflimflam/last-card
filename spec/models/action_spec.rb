require 'rails_helper'
require_relative 'shared_examples'

RSpec.shared_examples "invalid Action" do
  let(:model) { action }
  include_examples "invalid ActiveModel"
end

RSpec.describe Action, type: :model do
  let(:rank)   { Card::RANKS.first }
  let(:suit)   { Card::SUITS.first }
  let(:game)   { Game.create!     }
  let(:effect) { Action::PICKUP   }
  let(:user)   { User.create!(email: "mc@testers.on") }
  let(:player) { user.players.create!(game: game) }

  let(:action) do
    Action.new(
      card_suit: suit,
      card_rank: rank,
      player: player,
      effect: effect,
    )
  end

  context "when initializing" do
    context "with a player and a card" do
      it "is #valid?" do
        expect(action).to be_valid
      end

      it "can save" do
        action.save!
      end
    end

    context "with no parameters" do
      let(:action) { Action.new }
      include_examples "invalid Action"
    end

    context "without a player" do
      let(:player) { nil }
      include_examples "invalid Action"
    end

    context "without an effect" do
      let(:effect) { nil }
      include_examples "invalid Action"
    end

    context "without a rank" do
      let(:rank) { nil }
      include_examples "invalid Action"
    end

    context "without a suit" do
      let(:suit) { nil }
      include_examples "invalid Action"
    end

    context "with invalid suit" do
      let(:suit) { "dude bro party massacre 3" }
      include_examples "invalid Action"
    end

    context "with invalid rank" do
      let(:rank) { "kung fury" }
      include_examples "invalid Action"
    end
  end

  context "multiple actions" do
    it "can save references to the same card" do
      2.times do
        Action.create!(
          card_suit: suit,
          card_rank: rank,
          player: player,
          effect: effect,
        )
      end
    end
  end

  context "shuffle effects" do
    let(:effect) { Action::SHUFFLE }
    let(:card_rank) { nil }
    let(:card_suit) { nil }

    context "without player" do
      let(:player) { nil }
      include_examples "invalid Action"
    end

    context "with player" do
      it "can save" do
        action.save!
      end
    end
  end

  describe "#since" do
    let(:action1) { player.actions.build(effect: Action::SHUFFLE) }
    let(:action2) { player.actions.build(effect: Action::SHUFFLE) }

    before do
      action1.save!
      action2.save!
    end

    it "doesn't include action searched for" do
      expect(game.actions.since(action1.id)).to_not include action1
    end

    it "shows actions since specified id" do
      expect(game.actions.since(action1.id)).to include action2
    end

    it "excludes actions that happened before specified id" do
      expect(game.actions.since(action2.id)).to_not include action1
    end

    it "returns empty if nothing has happened since" do
      expect(game.actions.since(action2.id)).to be_empty
    end
  end
end
