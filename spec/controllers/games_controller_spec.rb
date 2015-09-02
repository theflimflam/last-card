require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  render_views # needed for response.body tests

  # User logged in is megatron
  let(:megatron) { User.create!(email: "megatron@decepticons.co.nz") }
  before { session[:user_id] = megatron.id }

  describe "GET new" do
    it "creates a game after called" do
      expect { get :new }.to change { Game.all.count }.by 1
    end

    it "redirects to game after called" do
      get :new
      expect(response).to redirect_to(Game.first)
    end
  end

  describe "GET index" do
    let(:game_pending) { Game.create! }
    let(:game_in_play) { Game.create!(pending: false) }

    before do
      game_pending # observe to create
      game_in_play # observe to create
      get :index
    end

    it "shows games that are pending" do
      expect(assigns(:games)).to include game_pending
    end

    it "does not show games that have started" do
      expect(assigns(:games)).to_not include game_in_play
    end

    it "renders the index template" do
      expect(response).to render_template('index')
    end
  end

  context "when joining a game" do
    let(:game) { Game.create! }

    context "GET show invalid game ID" do
      it "explodes with negative game id" do
        expect { get :show, id: -1 }.to raise_error ActiveRecord::RecordNotFound
      end

      it "explodes with alpha game id" do
        expect { get :show, id: "fu" }.to raise_error ActiveRecord::RecordNotFound
      end

      it "explodes with non existant game id" do
        expect { get :show, id: 666 }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "GET show" do
      subject { get :show, id: game.id }

      it "can find a game in progress" do
        subject
        expect(response).to render_template('show')
      end

      it "publishes a JOIN action" do
        expect { subject }
          .to change { Action.where(effect: Action::JOIN).count }
          .by 1
      end

      it "created a new player" do
        expect { subject }.to change { Player.count }.by 1
      end

      it "doesn't create a player on page refresh" do
        subject
        expect { subject }.to_not change { Player.count }
      end
    end

    describe "PUT update" do
      subject { put :update, id: game.id, ready: true }

      context "with one player" do
        it "doesn't start the game" do
          expect { subject }.to_not change { game.started? }.from false
        end

        it "still isn't #ready?" do
          expect { subject }.to_not change { game.ready? }.from false
        end

        it "still isn't #ready?" do
          expect { subject }.to_not change { game.ready? }.from false
        end
      end

      context "with two players" do
        let(:optimus) { User.create!(email: "optimus@autobots.com.au") }
        let(:player) { megatron.players.find_by(game: game) }
        let(:oponent) { optimus.players.find_by(game: game) }

        before do # players have joined
          game.players.create!(user: optimus)
          game.players.create!(user: megatron)
        end

        it "shows game as #ready?" do
          expect(game).to be_ready
        end

        it "creates ready action on post" do
          expect { subject }
            .to change { player.actions.where(effect: Action::READY).count }
            .from(0).to(1)
        end

        it "doesn't affect other player's readyness on post" do
          expect { subject }.to_not change { oponent.actions.where(effect: Action::READY).count }
        end

        context "when both players are ready" do
          before { oponent.ready! }

          it "removes game pending flag" do
            expect { subject }.to change { game.reload.pending? }.from(true).to(false)
          end

          it "creates Action::START_GAME" do
            expect { subject }
              .to change { game.reload.actions.where(effect: Action::START_GAME).count }
              .from(0).to(1)
          end
        end
      end
    end
  end
end
