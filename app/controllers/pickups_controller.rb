class PickupsController < ApplicationController
  before_filter :setup_game
  before_filter :setup_round

  def create
    if pickup_service.call
      render_success
    else
      render_errors(pickup_service.errors)
    end
  end

  private

  def pickup_service
    PickupCards.new(player, round, pickup_count)
  end

  def round
    @round
  end

  def pickup_count
    [round.pile.pickup_count, 1].max
  end

  def pickup_params
    params.require(:pickup).permit(cards: [ :suit, :rank ])
  end

  def player
    game.players.find_by(user_id: user_id)
  end

  def user_id
    session[:user_id]
  end

  def game
    @game ||= Game.find(params[:game_id])
  end

end
