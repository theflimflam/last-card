CalculatePile = Struct.new(:game) do
  delegate :plays, :shuffles, to: :game

  def call
    Pile.new(cards)
  end

  private

  def cards
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
end
