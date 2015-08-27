class PickupCards < Struct.new(:player, :round, :number_of_pickups)
  def call
    round.game.with_lock do
      number_of_pickups.times do
        pickup_card
        break if errors.any?
      end
      end_turn
    end

    errors.none?
  end

  def errors
    @errors ||= []
  end

  private

  def pickup_card
    if round.deck.any?
      card = round.deck.pickup
      player.pickup!(card)
    else
      errors.push "no cards in deck"
    end
  end

  def end_turn
    round.game.round_counter += 1
  end
end
