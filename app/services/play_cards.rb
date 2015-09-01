class PlayCards < Struct.new(:player, :round, :cards)
  def errors
    @errors ||= []
  end

  def call
    round.game.with_lock do
      check_legal_move

      play_cards! && increment_round! if errors.none?
    end

    errors.none?
  end

  private

  # TODO push out to player_options class and use a validate method
  def check_legal_move
    if cards.count == 0
      errors.push "need to specify cards to play when calling play cards"
    elsif cant_play_on_pile?
      errors.push "cannot play card #{cards.first} on #{round.pile.top}"
    elsif cards_of_different_rank?
      errors.push "when playing cards together, they must all be of same suit"
    end
  end

  def play_cards!
    cards.each { |card| player.play!(card) }
  end

  def increment_round!
    player.end_turn!
    round.game.save!
  end

  def cards_of_different_rank?
    cards.map(&:rank).uniq.count > 1
  end

  def cant_play_on_pile?
    !cards.first.playable_on?(round.pile.top)
  end
end
