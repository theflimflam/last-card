class Action < ActiveRecord::Base
  PICKUP     = 'pickup'
  PLAY       = 'play'
  SHUFFLE    = 'shuffle'
  SET_TURN   = 'set_turn'
  LAST_CARD  = 'last_card'
  WINNER     = 'winner'

  belongs_to :player

  composed_of :card, class_name: "Card", mapping: [%w(card_rank rank), %w(card_suit suit)]

  # Read this and break up class :)
  # http://eewang.github.io/blog/2013/03/12/how-and-when-to-use-single-table-inheritance-in-rails/
  scope :pickups,  -> { where(effect: PICKUP) }
  scope :plays,    -> { where(effect: PLAY) }
  scope :shuffles, -> { where(effect: SHUFFLE) }
  scope :turns,    -> { where(effect: SET_TURN) }

  scope :since, ->(id) { where('actions.id > ?', id) }

  scope :in_order, -> { order(:id) }

  validates :player, presence: true
  validates :effect, inclusion: { in: [ PICKUP, PLAY, SHUFFLE, SET_TURN ] }

  validates :card_suit, inclusion: { in: Card::SUITS }, if: :requires_card?
  validates :card_rank, inclusion: { in: Card::RANKS }, if: :requires_card?

  private

  # TODO subclass each of these action types and have specific validations there
  # ...class PickupAction < Action
  # ...class PlayAction < Action
  def requires_card?
    effect == PICKUP || effect == PLAY
  end
end
