class PickupCards < Struct.new(:player, :round, :number_of_pickups)
  def call
    round.game.with_lock do
      validate_cards_available
      pickup_card if errors.none?
    end

    errors.none?
  end

  def errors
    @errors ||= []
  end

  private

  def validate_cards_available
    # TODO this seems to imply the shuffle service needs to exist
    # see also pickup_cards_spec -> context "pickup 5"
    errors << "not enough cards in deck" if round.deck.size < number_of_pickups
  end

  def pickup_card
    number_of_pickups.times do
      card = round.deck.pickup
      player.pickup!(card)
    end
  end

  # TODO increment round fool!
end
