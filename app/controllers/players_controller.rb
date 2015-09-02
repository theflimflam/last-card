class PlayersController < ApplicationController
  def index
    render(json: format_players)
  end

  def show
    player = game.players.find(show_id)
    render(json: format_player(player))
  end

  private

  def format_players
    game.players.all.map { |player| format_player(player) }
  end

  def format_player(player)
    {
      id:   player.id,
      name: player.name,
      role: role(player),
    }
  end

  def game
    @game ||= Game.find(params[:game_id])
  end

  def role(player)
    if player.user_id == session[:user_id]
      "player"
    else
      "oponent"
    end
  end

  def show_id
    params.require(:id)
  end
end
