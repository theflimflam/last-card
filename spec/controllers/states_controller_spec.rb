require 'rails_helper'

RSpec.describe StatesController, type: :controller do
  let(:game) { Game.create! }
  let(:megatron) { User.create!(email: "megatron@decepticons.com") }
  let(:optimus) { User.create!(email: "optimus@prime.net") }

  before do
    session[:user_id] = megatron.id
    game.players.create!(user: megatron)
    game.players.create!(user: optimus)
  end

  describe "#show" do
    subject { get :show }

    context "when game has been setup" do
      # it "lists the players"
      # it "lists the player"
      # it "lists oponents"
    end
  end
end
