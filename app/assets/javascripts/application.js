/* global d3, $, window */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require_tree .

function last(list) {
  return list.slice(-1)[0];
}

var cardDimensions = (function(){
  var $svg = $('svg');
  var height = Math.min($svg.height(), $svg.width()) / 6;
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
  var DECK_SPEAD = cardDimensions.width / 2; // half a card

  function positionDeck() {
    return function(c, i) {
      var offset = i / MAX_CARDS * DECK_SPEAD; // px
      var position = 'translate(50,0)';
      var stack = 'translate(' + offset + ',' + offset + ')';
      var perspective = 'skewX(-10) skewY(10)';
      return [position, stack, perspective].join(' ');
    };
  }

  return {
    deck: positionDeck
  };
})();

function onGamePage() {
  var path = document.location.pathname;
  var gamePage = RegExp('^/games/\\d+');
  return !!path.match(gamePage);
}

$(document).ready(function initScripts() {
  if (!onGamePage()) {
    return new Error('this script only to run on game pages');
  }

  function keyedByCard(card) { return [card.rank, card.suit].join(','); }
  function cardFace(card) { return card.image; }

  var svg = d3.select('svg');

  // Poor man's updates
  run();
  setInterval(run, 1500);

  function run() {
    var gameStatePromise = resource.gameState();
    gameStatePromise.then(renderDeck);
    gameStatePromise.then(renderPlayers);
  }

  function renderDeck(state) {
    var cards = svg.selectAll('.card').data(state.deck, keyedByCard);

    cards.enter()
      .append('image').classed('card', true)
        .attr('xlink:href', cardFace)
        .attr('height', cardDimensions.height)
        .attr('width', cardDimensions.width)
    ;

    cards.attr('transform', positionHelpers.deck(cards));
  }

  function renderPlayers(state) {
    // TODO
    console.log(state);
  }
});
