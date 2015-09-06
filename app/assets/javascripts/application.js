/* global d3, $, window */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require_tree .

// function signalReady() {
//   return $.ajax({
//     url:    document.location,
//     method: 'put',
//     data:   { ready: true }
//   });
// }

// var pollActions = (function() {
//   var state = [];

//   function sinceLastAction() {
//     if ( state.length > 0 ) {
//       return { since: last(state).id };
//     }
//   }

//   function updateCache(newState) {
//     state = state.concat(newState);
//     return state;
//   }

//   return function pollActions() {
//     return getActionsJSON(sinceLastAction())
//       .then(updateCache);
//   };
// })();

// function last(list) {
//   return list.slice(-1)[0];
// }

// function getActionsJSON(params) {
//   return $.getJSON(document.location + '/actions', params);
// }

function getGameState() {
  return $.getJSON(document.location + '/state');
}

function keyedByCard(card) {
  return [card.rank, card.suit].join(',');
}

function cardFace(card) {
  return card.image;
}

$(document).ready(function initScripts() {
  var CARD_HEIGHT = 150;
  var CARD_WIDTH = 100;

  var path = document.location.pathname;
  var gamePage = RegExp('^/games/\\d+');

  if (!path.match(gamePage)) {
    return new Error('only runs on game pages');
  }

  var game = null;
  var svg = d3.select('svg');

  // Poor man's updates
  setInterval(run, 1500);
  run();

  function run() {
    var gameStatePromise = getGameState(game);
    gameStatePromise.then(renderDeck);
    gameStatePromise.then(renderPlayers);
  }

  function renderDeck(state) {
    var cards = svg.selectAll('.card').data(state.deck, keyedByCard);

    cards.enter()
      .append('image').classed('card', true)
        .attr('xlink:href', cardFace)
        .attr('height', CARD_HEIGHT)
        .attr('width', CARD_WIDTH)
    ;

    cards.attr('transform', positionDeck(cards));
  }

  function renderPlayers(state) {
    // TODO
    console.log(state);
  }

  function positionDeck() {
    return function(c, offset) {
      var position = 'translate(50,0)';
      var stack = 'translate(' + offset + ',' + offset + ')';
      var perspective = 'skewX(-10) skewY(10)';
      return [position, stack, perspective].join(' ');
    };
  }
});
