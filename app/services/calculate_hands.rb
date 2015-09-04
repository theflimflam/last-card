CalculateHands = Struct.new(:game) do
  delegate :players, to: :game

  def call
    players.each.with_object({}) do |player, hands|
      hands[player.id] = hand(player)
    end
  end

  private

  def hand(player)
    pickup_cards = player.pickups.map(&:card)
    play_cards = player.plays.map(&:card)
    Hand.new(pickup_cards).without(play_cards)
  end
end
