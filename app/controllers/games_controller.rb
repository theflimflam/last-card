class GamesController < ApplicationController
  wrap_parameters format: %i(json xml url_encoded_form multipart_form)

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
    # TODO security risk?
    if params[:ready]
      find_or_create_player.update!(ready: true)

      if game.ready? && game.players.map(&:ready?).all?
        if !start_game.call
          raise "Game failed to start: #{start_game.errors.to_sentence}"
        end
      end
    end

    render_success
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
    redirect_to 'sessions#destroy'
  end

  def start_game
    @start_game ||= StartGame.new(game)
  end
end
