require 'rails_helper'

RSpec.shared_examples "chainable methods" do
  context "when called" do
    it "returns another Hand" do
      expect(subject).to be_a_kind_of Hand
    end
  end
end

RSpec.shared_examples "subject returns no cards" do
  it "returns no cards" do
    expect(subject.size).to be 0
  end
end

RSpec.describe Hand do
  let(:cards) do
    [ Card.new('queen','hearts'),
      Card.new('4','spades'),
      Card.new('queen','spades') ]
  end

  let(:hand) { Hand.new(cards) }

  describe "#select_playable" do
    # TODO when top card has been played as an ace
    context "when top card doesn't share suit or rank" do
      subject { hand.select_playable(Card.new('3', 'diamonds')) }
      include_examples "subject returns no cards"
    end

    context "when top card shares suit" do
      subject { hand.select_playable(Card.new('3', 'spades')) }

      it "returns spades" do
        expect(subject).to include Card.new('4', 'spades')
      end

      it "leaves behind other suits" do
        expect(subject).to_not include Card.new('queen', 'hearts')
      end
    end

    context "when top card shares rank" do
      subject { hand.select_playable(Card.new('queen', 'diamonds')) }

      it "returns queens" do
        expect(subject).to include Card.new('queen', 'spades')
      end

      it "leaves out other cards" do
        expect(subject).to_not include Card.new('4', 'spades')
      end
    end
  end

  describe "#pickup_defence" do
    let(:top_card) { Card.new('2', 'hearts') }
    subject { hand.pickup_defence(top_card) }

    context "when hand has no defence" do
      include_examples "subject returns no cards"
    end

    context "when hand has pickup" do
      let(:suit) { 'hearts' }
      let(:card) { Card.new('5', suit) }

      before { hand.push(card) }

      it "offers up the pickup card" do
        expect(subject).to include card
      end

      context "but they're of the wrong suit" do
        let(:suit) { 'clubs' }
        include_examples "subject returns no cards"
      end
    end

    context "when hand has block" do
      let(:suit) { 'hearts' }
      let(:card) { Card.new('7', suit) }

      before { hand.push(card) }

      it "offers up the block card" do
        expect(subject).to include card
      end

      context "but it's of the wrong suit" do
        let(:suit) { 'clubs' }
        include_examples "subject returns no cards"
      end
    end
  end

  describe "#without" do
    RSpec::Matchers.define_negated_matcher :to_not_include, :include

    let(:missing_card) { cards.last }
    subject { hand.without([missing_card]) }

    it "removes cards from the hand" do
      expect { subject }.to change { hand }.to(to_not_include missing_card)
    end

    it "is chainable" do
      expect(subject).to be_a(Hand)
    end
  end

  describe "#last_card?" do
    context "with cards of same rank" do
      let(:cards) do
        [ Card.new('queen','hearts'),
          Card.new('queen','diamonds') ]
      end

      it "is #last_card?" do
        expect(hand).to be_last_card
      end
    end

    context "with cards of different rank" do
      let(:cards) do
        [ Card.new('jack','diamonds'),
          Card.new('queen','diamonds') ]
      end

      it "is #last_card?" do
        expect(hand).to_not be_last_card
      end
    end
  end
end
