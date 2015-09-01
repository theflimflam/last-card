class ActionsController < ApplicationController
  def index
    render(json: actions.in_order)
  end

  private

  def actions
    last_time = index_params[:since]
    if last_time
      game.actions.since(last_time)
    else
      game.actions
    end
  end

  def index_params
    params.permit(:since)
  end

  def game
    @game ||= Game.find(params[:game_id])
  end
end
