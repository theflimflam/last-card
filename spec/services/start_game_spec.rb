require 'rails_helper'
require_relative 'shared_examples'

RSpec.describe StartGame do
  # predictable seed for predictable shuffles
  before { srand 1 }

  let(:user1) { User.create!(email: "batman")   }
  let(:user2) { User.create!(email: "tothemax") }
  let(:game)    { Game.create! }
  let(:service) { StartGame.new(game) }

  context "when called" do
    context "before users have joined" do
      it_behaves_like "a service with errors"
    end

    context "and game not #ready?" do
      before { game.users << user1 }
      it_behaves_like "a service with errors"
    end

    context "more than once" do
      let(:second_service) { StartGame.new(game) }

      before do
        game.users << user1
        game.users << user2
        second_service.call or raise "need to start game to test a second starting"
      end

      it "doesn't create new START_GAME actions" do
        expect { service.call }
          .to_not change { game.actions.where(effect: Action::START_GAME).count }
      end

      it_behaves_like "a service with errors"
    end

    context "and game is #ready?" do
      before do
        game.users << user1
        game.users << user2
      end

      subject { service.call }

      it "runs" do
        expect(subject).to be true
      end

      it "has no errors" do
        expect { subject }
          .to_not change { service.errors.size }
      end

      it "is no longer #pending" do
        expect { subject }
          .to change { game.pending }
          .from(true).to(false)
      end

      it "creates a START_GAME action" do
        expect { subject }
          .to change { game.actions.where(effect: Action::START_GAME).count }
          .by 1
      end

      it "deals cards to users" do
        expect { subject }
          .to change { Action.pickups.count - Action.plays.count }
          .from(0).to(10) # 10 cards in users hands
      end

      it "plays the first card on the deck" do
        expect { subject }
          .to change { Action.plays.size }
          .from(0).to(1)
      end

      it "does not repeat delt cards to users" do
        expect { subject }
          .to change { Action.pickups.map(&:card).uniq.size }
          .from(0).to(11) # 11 unique cards, 1 will be played
      end
    end
  end
end
