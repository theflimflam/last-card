class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :actions, dependent: :destroy

  validates :user, presence: true
  validates :game, presence: true

  delegate :name, to: :user
  delegate :plays, :pickups, :shuffles, to: :actions

  def pickup!(card)
    pickups.create!(card: card)
  end

  def play!(card)
    plays.create!(card: card)
  end

  def shuffle!
    shuffles.create!
  end

  def set_turn!
    actions.create!(effect: Action::SET_TURN)
  end

  def ready!
    with_lock do
      if !ready?
        actions.create!(effect: Action::READY)
      end
    end
  end

  def ready?
    actions.where(effect: Action::READY).count > 0
  end
end
