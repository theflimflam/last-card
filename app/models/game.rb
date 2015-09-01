class Game < ActiveRecord::Base
  MINIMUM_PLAYERS = 2

  has_many :players, dependent: :destroy

  has_many :users, through: :players
  has_many :actions, through: :players
  delegate :plays, :pickups, :shuffles, to: :actions

  # TODO should a user kill themselves
  # we should end the game

  def ready?
    players.count >= MINIMUM_PLAYERS
  end

  def started?
    !pending
  end

  def current_player
    turn_counter = actions.turns.count
    players[turn_counter % players.count]
  end
end
