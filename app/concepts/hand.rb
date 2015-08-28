# TODO wrap array in PORO
class Hand < Array
  def select_playable(top_card)
    select_from_hand { |card| card.playable_on?(top_card) }
  end

  def pickup_defence(top_card)
    select_playable(top_card)
      .select_from_hand { |card| card.pickup? || card.block? }
  end

  protected

  def select_from_hand(&block)
    cards = select(&block)
    Hand.new(cards)
  end
end
