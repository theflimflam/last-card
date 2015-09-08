/* global d3, $, Resources, CardDimensions, PositionHelpers, Util */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require_tree .
var table = d3.select('svg#table');

function cardRankSuit(card) {
  return card.rank && [card.rank, card.suit].join(',');
}
function actionRankSuit(action) {
  return action.card_rank && [action.card_rank, action.card_suit].join(',');
}
function keyedByCard(object) {
  return cardRankSuit(object) || actionRankSuit(object);
}
function cardFace(card)     { return card.image;                                     }
function objectID(obj)      { return obj.id;                                         }
function playerName(player) { return player.name;                                    }
function findME(player)     { return player.role === 'player';                       }
function ready(player)      { return player.ready;                                   }

$(document).ready(function initScripts() {
  if (!onGamePage()) {
    return new Error('this script only to run on game pages');
  }

  // Poor man's updates
  run();
  // setInterval(run, 1000);
  setTimeout(run, 1000);

  function gameStarted() {
    var hasCache = ( typeof cache !== 'undefined' );
    var hasState = hasCache && ( typeof cache.state !== 'undefined' );
    return hasState && cache.state.started;
  }

  function run() {
    if (!gameStarted()) {
      Resources.gameState()
        .then(cacheState)
        .then(initDeck)
        .then(updatePlayerReadyness)
      ;
    }
    else {
      table.selectAll('.player').remove();

      Resources.actions()
        .then(pickupCards)
        .then(playCards)
      ;
    }
  }
});

var cache = {};
function cacheState(state) {
  cache.state = state;
  return state;
}

function onGamePage() {
  var path = document.location.pathname;
  var gamePage = RegExp('^/games/\\d+');
  return !!path.match(gamePage);
}

function initDeck(state) {
  var cards = table.selectAll('.card').data(state.deck, keyedByCard);

  cards.enter()
    .append('image').classed('card', true)
      .attr('xlink:href', cardFace)
      .attr('height', CardDimensions.height)
      .attr('width', CardDimensions.width)
  ;

  cards.attr('transform', PositionHelpers.deck(cards));

  return state;
}

function updatePlayerReadyness(state) {
  var players = table.selectAll('.player').data(state.players, objectID);
  var newPlayers = players.enter().append('g').classed('player', true);

  newPlayers
    .append('text').classed('name',true)
      .attr('transform', PositionHelpers.translate(20, 0))
      .text(playerName)
  ;

  newPlayers.filter(findME).attr('fill','blue').on('click', Resources.signalReady);

  newPlayers.append('text').classed('ready',true).text('✖');
  players.filter(ready).selectAll('.ready').text('✔');

  players.attr('transform', PositionHelpers.player);
}


function playCards() {
}

function pickupCards(actions) {
  var pickupActions = actions.filter(Util.effect('pickup'));
  var pickups = table.selectAll('.card').data(pickupActions, keyedByCard);

  pickups.moveToFront();
  table.selectAll('.card').attr('transform', PositionHelpers.deck());

  PositionHelpers.transitionFlickOut(pickups)
    .attr('transform', PositionHelpers.hand(pickups));
}
