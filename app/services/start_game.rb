class StartGame
  attr_reader :errors

  def initialize(game)
    @game = game
    @errors = []
  end

  def call
    @game.with_lock do
      flag_started!

      shuffle_deck && divvy_up_cards! if errors.none?
    end

    @errors.none?
  end

  private

  def check_game_ready
    if @game.ready?
      true
    else
      @errors.push "game not ready to start"
      false
    end
  end

  def flag_started!
    if !@game.ready?
      @errors.push "game not ready to start"
    elsif !@game.pending
      @errors.push "game already started"
    else
      # TODO remove pending from game
      @game.update!(pending: false)
      dealer.actions.create!(effect: Action::START_GAME)
    end
  end

  def shuffle_deck
    @deck = Deck::PLATONIC.shuffle
  end

  def divvy_up_cards!
    give_players_cards! && play_first_card!
  end

  def give_players_cards!
    @game.players.each do |player|
      @deck.pop(5).each do |card|
        player.pickup!(card)
      end
    end
  end

  def play_first_card!
    first_card = @deck.pop
    dealer.pickup!(first_card)
    dealer.play!(first_card)
  end

  def dealer
    @game.players.first
  end
end
