class Round < Struct.new(:game)
  def hands
    return @hands if @hands.present?

    @hands = {}
    if game.started?
      game.players.each do |player|
        pickups = player.pickups.map(&:card)
        plays = player.plays.map(&:card)
        @hands[player.nickname] = Hand.new(pickups - plays)
      end
    end

    @hands
  end

  def deck
    @deck ||= calculate_deck
  end

  def pile
    return @pile if @pile.present?

    if game.started?
      @pile = Pile.new(calculate_shuffled_pile)
    else
      @pile = Pile.new([])
    end
  end

  private

  # FIXME 52 pickups is fine for the first shuffle
  # But subsequent pickups will trigger from running through the deck height
  # which will not be 52 the second time
  # If the deck is size 20 after the first shuffle
  # the second shuffle will be at 72 pickups!
  def calculate_shuffled_pile
    shuffle_count = game.pickups.count / Card::DECK.size

    # Just return played cards if we've not shuffled yet
    return game.plays.map(&:card) if shuffle_count.zero?

    # Find the card that triggered the shuffle
    @shuffle_trigger = game.pickups[ Card::DECK.size * shuffle_count - 1 ]

    # Pile will be previous pile's top card + played cards since then
    previous_top_card.concat played_since_shuffle
  end

  def previous_top_card
    [ plays_before_shuffle.last ]
  end

  def plays_before_shuffle
     game.plays.where("actions.id < ?", @shuffle_trigger.id).map(&:card)
  end

  def played_since_shuffle
    game.plays.where("actions.id > ?", @shuffle_trigger.id).map(&:card)
  end

  def cards_in_play
    pile + hands.values.flatten
  end

  def calculate_deck
    deck_cards = Card::DECK - cards_in_play
    Deck.new(deck_cards)
  end
end
