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
    update_player_readyness!

    start_game! if game_can_start?

    render_success
  end

  private

  def update_player_readyness!
    if player_ready?
      find_or_create_player.update!(ready: true)
    end
  end

  def game_can_start?
    game.ready? && game.players.map(&:ready?).all?
  end

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
    redirect_to '/logout'
  end

  def start_game!
    service = StartGame.new(game)
    if !service.call
      raise "Game failed to start: #{service.errors.to_sentence}"
    end
  end

  def player_ready?
    # TODO security risk?
    params[:ready]
  end
end
