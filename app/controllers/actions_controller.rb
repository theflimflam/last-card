class ActionsController < ApplicationController
  def index
    last_checked = index_params.since
    if last_checked
      game.actions.since(last_checked)
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
