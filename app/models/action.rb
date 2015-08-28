class Action < ActiveRecord::Base
  PICKUP = 'pickup'
  PLAY = 'play'
  SHUFFLE = 'shuffle'

  belongs_to :player

  composed_of :card, class_name: "Card", mapping: [%w(card_rank rank), %w(card_suit suit)]

  # Read this and break up class :)
  # http://eewang.github.io/blog/2013/03/12/how-and-when-to-use-single-table-inheritance-in-rails/
  scope :pickups,  -> { where(effect: PICKUP) }
  scope :plays,    -> { where(effect: PLAY) }
  scope :shuffles, -> { where(effect: SHUFFLE) }
  scope :in_order, -> { order(:id) }

  validates :player, presence: true
  validates :effect, inclusion: { in: [ PICKUP, PLAY, SHUFFLE ] }

  validates :card_suit, inclusion: { in: Card::SUITS }, unless: :this_triggered_shuffle?
  validates :card_rank, inclusion: { in: Card::RANKS }, unless: :this_triggered_shuffle?

  private

  def this_triggered_shuffle?
    effect == SHUFFLE
  end
  # TODO wrap array in PORO
end
