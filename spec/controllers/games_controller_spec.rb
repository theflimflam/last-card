require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  render_views # needed for response.body tests

  # User logged in is megatron
  let(:megatron) { User.create!(email: "megatron@decepticons.com") }
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
      # let(:game) { Game.create! }
      # let(:user1) { User.create!(email: "a@a.a") }
      # let(:user2) { User.create!(email: "b@b.b") }

      # before do
      #   game.players.create!(user: user1)
      # end

      # context "when there is only one player" do
      #   it "doesn't start the game" do
      #     expect().to raise
      #   end
      # end

      # context "when there are 2 players" do
      #   before { game.players.create!(user: user2) }

      #   context "where one player is ready" do
      #     it ""
      #   end

      #   context "when both players are ready" do
      #     it "starts the game"
      #   end
      # end
    end
  end
end
