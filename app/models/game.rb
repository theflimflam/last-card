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
    player_turn(count_turns)
  end

  def next_player
    player_turn(count_turns + 1)
  end

  private

  def count_turns
    actions.turns.count
  end

  def player_turn(offset)
    players[offset % players.count]
  end
end
