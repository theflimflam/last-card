class Deck < Array
  # Traditional full 52 card deck
  PLATONIC = Card::RANKS
    .product(Card::SUITS)
    .map { |rank, suit| Card.new(rank, suit) }
    .freeze

  def pickup
    shuffle_offset = rand(length)
    delete_at(shuffle_offset)
  end
end
