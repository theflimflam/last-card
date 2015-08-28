class Game < ActiveRecord::Base
  MINIMUM_PLAYERS = 2

  has_many :players, dependent: :destroy

  has_many :users, through: :players
  has_many :actions, through: :players
  delegate :plays, :pickups, :shuffles, to: :actions

  # TODO not null this field
  validates :round_counter, numericality: { only_integer: true }

  # TODO should a user kill themselves
  # we should end the game

  def ready?
    players.count >= MINIMUM_PLAYERS
  end

  def started?
    !pending
  end

  def current_player
    turn = round_counter % players.count
    players[turn]
  end
end
