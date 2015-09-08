/* global window, CardDimensions */
window.PositionHelpers = (function() {
  var MAX_CARDS = 52;
  var DECK_SPEAD = CardDimensions.width * 0.5;
  var CARD_HEIGHT = CardDimensions.height;
  var CARD_WIDTH = CardDimensions.width;
  var TRANSITION_TIME = 750; // ms

  var SEED = new Date().getTime() * Math.random();
  function seedRandom(seed) {
    return function myRandom() {
      var x = Math.sin(seed++) * 10000;
      return x - Math.floor(x);
    };
  }

  // DECK_SPREAD + CardDimensions.width = 1.5 cards wide
  function rotateCardAboutCenter(rotation) {
    return 'rotate(' +
      rotation + ',' +
      (CARD_WIDTH / 2).toString() + ',' +
      (CARD_HEIGHT / 2).toString() +
    ')';
  }

  function translate(x,y) {
    if (typeof y === 'undefined') { y = x; }
    return 'translate(' + x + ',' + y + ')';
  }

  function positionDeck() {
    var ANGLE               = 10;
    var CORRECTION_X        = CARD_WIDTH * 0.15;
    var CORRECTION_Y        = CARD_HEIGHT * 0.08;
    var PERSPECTIVE         = rotateCardAboutCenter(ANGLE);
    var CORRECT_PERSPECTIVE = translate(CORRECTION_X, CORRECTION_Y);
    var POSITION            = translate(CARD_HEIGHT);

    return function(c, i) {
      var height = i / MAX_CARDS * DECK_SPEAD; // px
      var stack = translate(height, height);

      return [POSITION, stack, PERSPECTIVE, CORRECT_PERSPECTIVE].join(' ');
    };
  }

  function positionHand(cards) {
    var POSITION = translate(CARD_HEIGHT*3);
    var count = cards[0].length;
    var fanAngle = calculateHandFanAngle(count);
    var startAngle = (fanAngle * count) / 2;

    return function fanOutCard(card, i) {
      var angle = (i * fanAngle) - startAngle;
      var selectionMultiplier = (card.selected ? -1.2 : -1);
      var rotate = 'rotate(' + angle + ', ' + (CARD_WIDTH/2) + ', ' + (CARD_HEIGHT/2) + ')';
      var pushOut = 'translate(0,' + (CARD_HEIGHT * selectionMultiplier) + ')';
      return [POSITION, rotate, pushOut].join(' ');
    };
  }

  var MINIMUM_CARD_ANGLE = 3; // degrees
  var MAXIMUM_CARD_ANGLE = 10; // degrees
  function calculateHandFanAngle(count) {
    var angle = 90 / count;

    if (angle > MAXIMUM_CARD_ANGLE) {
      return MAXIMUM_CARD_ANGLE;
    }
    else if (angle < MINIMUM_CARD_ANGLE) {
      return MINIMUM_CARD_ANGLE;
    }
    else {
      return angle;
    }
  }

  var VERTICAL_SPACING = 20;
  var HORIZONTAL_OFFSET = CARD_HEIGHT * 3.5;
  var VERTICAL_OFFSET = CARD_HEIGHT * 2;
  function positionPlayer(player, i) {
    var y = i * VERTICAL_SPACING + VERTICAL_OFFSET;
    return translate(HORIZONTAL_OFFSET, y);
  }

  function transitionFlickOut(cards) {
    var cardCount = cards[0].length;

    return cards.transition()
      .delay(staggeredDelay(TRANSITION_TIME, cardCount)) // stagger transitions over a second
      .duration(TRANSITION_TIME)                         // transition over 1/2 a second
      .ease('exp-in-out')                                // as if the user flicked it into the table
    ;
  }

  function staggeredDelay(msDelay, itemsCount) {
    return function myDelay(d, i) {
      var depth = (itemsCount - i) / itemsCount;
      return depth * msDelay;
    };
  }

  function positionPile() {
    var random = seedRandom(SEED);
    var POSITION = translate(CARD_HEIGHT*3, 0);

    return function() {
      var rotation = random() * 180;
      var rotate = rotateCardAboutCenter(rotation);
      return [POSITION, rotate].join(' ');
    };
  }

  return {
    deck:               positionDeck,
    hand:               positionHand,
    pile:               positionPile,
    player:             positionPlayer,
    rotateCard:         rotateCardAboutCenter,
    transitionFlickOut: transitionFlickOut,
    translate:          translate
  };
})();
