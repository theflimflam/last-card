class GamesController < ApplicationController
  before_filter :lookup_user

  def new
    redirect_to Game.create!
  end

  def index
    @games = Game.where(pending: true)
  end

  def show
    game.with_lock do
      find_or_create_player
    end
  end

  def update
    # Set player readiness
    player.ready = !!update_params.ready

    if player.ready? && game.ready? && game.players.map(&:ready?).all?
      start_game.call or raise "Game failed to start: #{start_game.errors.to_sentence}"
    end
  end

  private

  def game
    @game ||= Game.find(params[:id])
  end

  def find_or_create_player
    @player ||= game.players.find_or_create_by(user: @user)
  end

  def lookup_user
    if session[:user_id]
      @user ||= User.find(session[:user_id])
    end
  rescue ActiveRecord::RecordNotFound
    @user = nil # so user isn't logged in after all
  end

  def update_params
    params.require(:ready)
  end

  def start_game
    @start_game ||= StartGame.new(game)
  end
end
