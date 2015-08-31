/* global $, d3 */
/* eslint-disable no-console */

$(document).ready(function() {
  var CARD_HEIGHT = 150;
  var CARD_WIDTH = 100;
  var SEED = new Date().getTime() * Math.random();
  var TRANSITION_TIME = 750; // ms

  var MINIMUM_CARD_ANGLE = 3; // degrees
  var MAXIMUM_CARD_ANGLE = 10; // degrees

  d3.json(document.location + '/rounds')
    .header('Content-Type', 'application/json')
    .get(initGame)
  ;

  function initGame(error, roundData) {
    if(error) {
      return console.error(error);
    }

    var cards = svg.selectAll('.card').data(roundData, keyedByCard);

    // Create svg elements for new cards
    cards.enter()
      .append('image').classed('card', true)
        .attr('xlink:href', cardImageUrl)
        .attr('height', CARD_HEIGHT)
        .attr('width', CARD_WIDTH)
        .attr('x',0)
        .attr('y',0)
    ;

    //cards.attr('transform', positionDeck(cards));
    cards.attr('transform', positionHand(cards));

    //everythingFlysAround(cards);
  }

  function everythingFlysAround(cards) {
    function render() {
      transitionFlickOut(cards)
        .attr('transform', positionHand(cards));

      setTimeout(function() {
        transitionFlickOut(cards)
          .attr('transform', positionPile(cards));
      },2000);

      setTimeout(function() {
        transitionFlickOut(cards)
          .attr('transform', positionDeck(cards));
      },4000);
    }

    render();
    setInterval(render, 6000);
  }
  function keyedByCard(card) {
    return [card.rank, card.suit].join(',');
  }

  function cardImageUrl(card) {
    return card.url;
  }

  function rotateCardTransform(rotation) {
    return 'rotate(' +
      rotation + ',' +
      (CARD_WIDTH/2+10).toString() + ',' +
      (CARD_HEIGHT/2+10).toString() +
    ')';
  }

  function randomColor() {
    return '#'+((1<<24)*Math.random()|0).toString(16);
  }

  function seedRandom(seed) {
    return function myRandom() {
      var x = Math.sin(seed++) * 10000;
      return x - Math.floor(x);
    };
  }

  function staggeredDelay(msDelay, itemsCount) {
    return function myDelay(d, i) {
      var depth = (itemsCount - i) / itemsCount;
      return depth * msDelay;
    };
  }

  function transitionFlickOut(cards) {
    var cardCount = cards[0].length;

    return cards.transition()
      .delay(staggeredDelay(TRANSITION_TIME, cardCount)) // stagger transitions over a second
      .duration(TRANSITION_TIME)                         // transition over 1/2 a second
      .ease('exp-in-out')                                // as if the user flicked it into the table
    ;
  }

  function positionDeck(cards) {
    var cardCount = cards[0].length;
    var random = seedRandom(SEED);

    return function(c, i) {
      var offset = cardCount + i;
      var angle = random() * 4 - 2;

      var position = 'translate(50,50)';
      var stack = 'translate(' + offset + ',' + offset + ')';
      var slightRotation = rotateCardTransform(angle);
      var perspective = 'skewX(-10) skewY(10)';
      return [position, stack, slightRotation, perspective].join(' ');
    };
  }

  function positionPile() {
    var random = seedRandom(SEED);

    return function() {
      var rotation = random() * 180;
      var position = 'translate(800,'+ (CARD_HEIGHT) +')';
      var rotate = rotateCardTransform(rotation);
      return [position, rotate].join(' ');
    };
  }

  function positionHand(cards) {
    var count = cards[0].length;
    var middle = parseFloat(count, 10) / 2;
    var fanAngle = calculateHandFanAngle(count);
    var startAngle = (fanAngle * count) / 2

    return function fanOutCard(card, i) {
      var angle = (i * fanAngle) - startAngle;
      var selectionMultiplier = (card.selected ? -1.2 : -1);
      var position = 'translate(300,300)';
      var rotate = 'rotate(' + angle + ', ' + (CARD_WIDTH/2) + ', ' + (CARD_HEIGHT/2) + ')';
      var pushOut = 'translate(0,' + (CARD_HEIGHT * selectionMultiplier) + ')';
      return [position, rotate, pushOut].join(' ');
    };
  }

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

  var svg = d3.select('#table')
    .attr('height', '100%')
    .attr('width', '100%')
  ;
});
