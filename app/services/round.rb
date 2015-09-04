# todo move to presenters
# todo move calculate_* to services
class Round < Struct.new(:game)
  delegate :plays, :pickups, :shuffles, :players, :next_player, to: :game

  def hands
    @hands ||= calculate_hands
  end

  def pile
    @pile ||= Pile.new(calculate_pile)
  end

  def deck
    @deck ||= Deck.new(calculate_deck)
  end

  def reset
    @hands, @deck, @pile = nil, nil, nil
    game.reload
  end

  private

  def calculate_pile
    shuffle_count = shuffles.count

    if shuffle_count.zero?
      # If we've not shuffled, just show all cards played
      plays.in_order.map(&:card)
    else
      # Otherwise, we need previous pile's top card + played cards since then
      previous_top_card.concat played_since_shuffle
    end
  end

  def previous_top_card
    [ plays_before_shuffle.last ]
  end

  def plays_before_shuffle
     plays.in_order.where("actions.id < ?", shuffle_trigger.id).map(&:card)
  end

  def played_since_shuffle
    plays.in_order.where("actions.id > ?", shuffle_trigger.id).map(&:card)
  end

  def shuffle_trigger
    shuffles.in_order.last
  end


  def cards_in_play
    pile + hands.values.flatten
  end

  # Change to be cheeper
  # 1. Find deck size from suffle trigger
  # 2. Remove pickups
  #   ...try make this work with scopes
  #   ...do add indexes to make this fast
  def calculate_deck
    Deck::PLATONIC - cards_in_play
  end

  def calculate_hands
    players.each.with_object({}) do |player, hands|
      pickup_cards = player.pickups.map(&:card)
      play_cards = player.plays.map(&:card)
      hands[player.id] = Hand.new(pickup_cards).without(play_cards)
    end
  end

  def empty_pile
    Pile.new
  end
end
