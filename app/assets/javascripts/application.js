/* global d3, $, window */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require_tree .

window.table = d3.select('svg#table');

function last(list)        { return list.slice(-1)[0]; }
function keyedByCard(card) { return [card.rank, card.suit].join(','); }
function cardFace(card)    { return card.image; }

var cardDimensions = (function(){
  var $svg = $('svg');
  var height = Math.min($svg.height(), $svg.width()) / 8;
  var width = height * (100/150);

  return {
    height: parseInt(height, 10),
    width: parseInt(width)
  };
})();

var pollActions = (function setupPollActions() {
  var state = {};
  var actionsSoFar = [];

  function pollMethod(params) {
    return $.getJSON(document.location + '/actions', params);
  }

  function updateState(actions) {
    if(actions.length > 0) {
      state.since = last(actions).id;
    }
    return actions;
  }

  function concatWithActionsSoFar(actions) {
    actionsSoFar = actionsSoFar.concat(actions);
    return actionsSoFar;
  }

  return function pollActions() {
    return pollMethod(state)
      .then(updateState)
      .then(concatWithActionsSoFar)
    ;
  };
})();

var resource = (function() {
  function gameState(params) {
    return $.getJSON(document.location + '/state', params);
  }

  function signalReady() {
    return $.ajax({
      url:    document.location,
      method: 'put',
      data:   { ready: true }
    });
  }

  return {
    gameState: gameState,
    actions: pollActions,
    signalReady: signalReady
  };
})();

var positionHelpers = (function() {
  var MAX_CARDS = 52;
  var DECK_SPEAD = cardDimensions.width * 0.5;

  // DECK_SPREAD + cardDimensions.width = 1.5 cards wide
  function rotateCardAboutCenter(rotation) {
    return 'rotate(' +
      rotation + ',' +
      (cardDimensions.width / 2).toString() + ',' +
      (cardDimensions.height / 2).toString() +
    ')';
  }

  function translate(x,y) {
    return 'translate(' + x + ',' + ( y || x ) + ')';
  }

  function positionDeck() {
    var ANGLE               = 10;
    var CORRECTION_X        = cardDimensions.width * 0.15;
    var CORRECTION_Y        = cardDimensions.height * 0.08;
    var PERSPECTIVE         = rotateCardAboutCenter(ANGLE);
    var CORRECT_PERSPECTIVE = translate(CORRECTION_X, CORRECTION_Y);
    var POSITION            = translate(cardDimensions.height * 2);

    return function(c, i) {
      var height = i / MAX_CARDS * DECK_SPEAD; // px
      var stack = 'translate(' + height + ',' + height + ')';

      return [POSITION, stack, PERSPECTIVE, CORRECT_PERSPECTIVE].join(' ');
    };
  }

  return {
    deck:       positionDeck,
    rotateCard: rotateCardAboutCenter
  };
})();

function onGamePage() {
  var path = document.location.pathname;
  var gamePage = RegExp('^/games/\\d+');
  return !!path.match(gamePage);
}

function initDeck(state) {
  var cards = window.table.selectAll('.card').data(state.deck, keyedByCard);

  cards.enter()
    .append('image').classed('card', true)
      .attr('xlink:href', cardFace)
      .attr('height', cardDimensions.height)
      .attr('width', cardDimensions.width)
  ;

  cards.attr('transform', positionHelpers.deck(cards));
}

$(document).ready(function initScripts() {
  if (!onGamePage()) {
    return new Error('this script only to run on game pages');
  }

  // Poor man's updates
  run();
  setInterval(run, 1500);

  function run() {
    resource.gameState().then(initDeck);
  }
});
