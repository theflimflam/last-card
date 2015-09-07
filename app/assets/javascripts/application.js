/* global d3, $, Resources, CardDimensions, PositionHelpers */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require_tree .

var table = d3.select('svg#table');

function cardName(card)     { return [card.rank, card.suit].join(','); }
function cardFace(card)     { return card.image;                       }
function objectID(obj)      { return obj.id;                           }
function playerName(player) { return player.name;                      }
function findME(player)     { return player.role === 'player';         }
function ready(player)      { return player.ready;                     }

function onGamePage() {
  var path = document.location.pathname;
  var gamePage = RegExp('^/games/\\d+');
  return !!path.match(gamePage);
}

function initDeck(state) {
  var cards = table.selectAll('.card').data(state.deck, cardName);

  cards.enter()
    .append('image').classed('card', true)
      .attr('xlink:href', cardFace)
      .attr('height', CardDimensions.height)
      .attr('width', CardDimensions.width)
  ;

  cards.attr('transform', PositionHelpers.deck(cards));
}

function updatePlayerReadyness(state) {
  var players = table.selectAll('.player').data(state.players, objectID);
  // var players = table.selectAll('.player').data(playa, objectID);
  var newPlayers = players.enter().append('g').classed('player', true);

  newPlayers
    .append('text').classed('name',true)
      .attr('transform', PositionHelpers.translate(20, 0))
      .text(playerName)
  ;

  newPlayers.filter(findME).attr('fill','orange').on('click', Resources.signalReady);

  newPlayers.append('text').classed('ready',true).text('✖');
  players.filter(ready).selectAll('.ready').text('✔');

  players.attr('transform', PositionHelpers.player);
}

$(document).ready(function initScripts() {
  if (!onGamePage()) {
    return new Error('this script only to run on game pages');
  }

  // Poor man's updates
  run();
  setInterval(run, 1500);

  function run() {
    var gameStatePromise = Resources.gameState();
    gameStatePromise.then(initDeck);
    gameStatePromise.then(updatePlayerReadyness);
  }
});
