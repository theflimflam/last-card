class Round < Struct.new(:game)
  delegate :plays, :pickups, :shuffles, :players, :next_player, to: :game

  def hands
    @hands ||= CalculateHands.new(game).call
  end

  def pile
    @pile ||= CalculatePile.new(game).call
  end

  def deck
    @deck ||= Deck.new(calculate_deck)
  end

  def reset
    @hands, @deck, @pile = nil, nil, nil
    game.reload
  end

  private

  def calculate_deck
    Deck::PLATONIC - cards_in_play
  end

  def cards_in_play
    pile + hands.values.flatten
  end
end
