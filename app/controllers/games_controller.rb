class GamesController < ApplicationController
  before_filter :lookup_user

  def new
    redirect_to Game.create!
  end

  def index
    @games = Game.where(pending: true)
  end

  def show
    @game = game
    @player = player
  end

  private

  def player
    @game.players.find_or_create_by(user: @user)
  end

  def game
    Game.find(params[:id])
  end

  def lookup_user
    if session[:user_id]
      @user ||= User.find(session[:user_id])
    end
  rescue ActiveRecord::RecordNotFound
    @user = nil # so user isn't logged in after all
  end
end
