class Card < ActiveRecord::Base
  belongs_to :action

  # TODO notes, Ruby makes these available as constants!
  # TODO what does freeze do?
  RANKS = %w( 2 3 4 5 6 7 8 9 10 jack queen king ace ).freeze
  SUITS = %w( hearts spades dimonds clubs ).freeze

  def ==(your)
    self.suit == your.suit && self.rank == your.rank
  end

  def hash
    [suit, rank].hash
  end

  validates :rank,
    presence: true,
    inclusion: { in: RANKS }

  validates :suit,
    presence: true,
    inclusion: { in: SUITS }

  # TODO is there a better way to enforce uniqueness?
  validates_uniqueness_of :suit, :scope => :rank

  def self.deck
    Card::RANKS.product(Card::SUITS).map do |rank, suit|
      Card.new(rank: rank, suit: suit)
    end
  end
end
