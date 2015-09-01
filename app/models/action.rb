class Action < ActiveRecord::Base
  PICKUP = 'pickup'
  PLAY = 'play'
  SHUFFLE = 'shuffle'
  START_GAME = 'start_game'

  belongs_to :player

  composed_of :card, class_name: "Card", mapping: [%w(card_rank rank), %w(card_suit suit)]

  # Read this and break up class :)
  # http://eewang.github.io/blog/2013/03/12/how-and-when-to-use-single-table-inheritance-in-rails/
  scope :pickups,  -> { where(effect: PICKUP) }
  scope :plays,    -> { where(effect: PLAY) }
  scope :shuffles, -> { where(effect: SHUFFLE) }
  scope :in_order, -> { order(:id) }

  validates :player, presence: true
  validates :effect, inclusion: { in: [ PICKUP, PLAY, SHUFFLE, START_GAME ] }

  validates :card_suit, inclusion: { in: Card::SUITS }, if: :pickup_or_play?
  validates :card_rank, inclusion: { in: Card::RANKS }, if: :pickup_or_play?

  private

  def pickup_or_play?
    effect == PICKUP || effect == PLAY
  end
  # TODO wrap array in PORO
end
