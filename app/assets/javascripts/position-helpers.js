/* global window, CardDimensions */
window.PositionHelpers = (function() {
  var MAX_CARDS = 52;
  var DECK_SPEAD = CardDimensions.width * 0.5;

  // DECK_SPREAD + CardDimensions.width = 1.5 cards wide
  function rotateCardAboutCenter(rotation) {
    return 'rotate(' +
      rotation + ',' +
      (CardDimensions.width / 2).toString() + ',' +
      (CardDimensions.height / 2).toString() +
    ')';
  }

  function translate(x,y) {
    return 'translate(' + x + ',' + ( y || x ) + ')';
  }

  function positionDeck() {
    var ANGLE               = 10;
    var CORRECTION_X        = CardDimensions.width * 0.15;
    var CORRECTION_Y        = CardDimensions.height * 0.08;
    var PERSPECTIVE         = rotateCardAboutCenter(ANGLE);
    var CORRECT_PERSPECTIVE = translate(CORRECTION_X, CORRECTION_Y);
    var POSITION            = translate(CardDimensions.height * 2);

    return function(c, i) {
      var height = i / MAX_CARDS * DECK_SPEAD; // px
      var stack = translate(height, height);

      return [POSITION, stack, PERSPECTIVE, CORRECT_PERSPECTIVE].join(' ');
    };
  }

  function positionPlayer(player, i) {
    var y = CardDimensions.width + i;
    var x = CardDimensions.height + i;
    return translate(x,y);
  }

  return {
    deck:       positionDeck,
    player:     positionPlayer,
    rotateCard: rotateCardAboutCenter
  };
})();

