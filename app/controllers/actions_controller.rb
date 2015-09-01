class ActionsController < ApplicationController
  def index
    last_time = index_params.since
    if last_time
      game.actions.since(last_time)
    else
      game.actions
    end
  end

  private

  def game
    @game ||= Game.find(params[:id])
  end

  def index_params
    params.permit(:since)
  end

end
