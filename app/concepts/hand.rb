# TODO wrap array in PORO
class Hand < Array
  def select_playable(top_card)
    select_from_hand { |card| card.playable_on?(top_card) }
  end

  def pickup_defence(top_card)
    select_playable(top_card)
      .select_from_hand { |card| card.pickup? || card.block? }
  end

  def without(cards)
    cards.each do |card|
      card_index = index(card)
      delete_at(card_index) if card_index
    end

    self # chainable
  end

  def last_card?
    # Declared if we're 1 move away from winning
    map(&:rank).uniq.count == 1
  end

  protected

  def select_from_hand(&block)
    cards = select(&block)
    Hand.new(cards)
  end
end
