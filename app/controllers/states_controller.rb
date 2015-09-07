class StatesController < ApplicationController
  def index
    render(json: game_state)
  end

  private

  def game_state
    {
      deck:    deck,
      players: players,
      started: game.started?,
    }
  end

  def deck
    Deck::PLATONIC.map do |card|
      {
        rank:  card.rank,
        suit:  card.suit,
        image: view_context.image_path(card.svg),
      }
    end
  end

  def players
    game.players.map do |player|
      {
        id:    player.id,
        name:  player.name,
        role:  user_role(player.user_id),
        ready: player.ready,
      }
    end
  end

  def user_role(id)
    if id == session[:user_id]
      "player"
    else
      "oponent"
    end
  end

  def game
    @game ||= Game.find(params[:game_id])
  end
end
