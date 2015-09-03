/* global d3, $, window, util */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require_tree .

function last(list) {
  return list.slice(-1)[0];
}

var keyByID = util.parameter('id');

function getActionsJSON(params) {
  return $.getJSON(document.location + '/actions', params);
}

//function getPlayerJSON(id) {
//  return $.getJSON(document.location + '/players/' + id);
//}

// function signalReady() {
//   return $.ajax({
//     url:    document.location,
//     method: 'put',
//     data:   { ready: true }
//   });
// }

var pollGameState = (function() {
  var state = [];

  function sinceLastAction() {
    if ( state.length > 0 ) {
      return { since: last(state).id };
    }
  }

  function updateCache(newState) {
    state = state.concat(newState);
    return state;
  }

  return function pollGameState() {
    return getActionsJSON(sinceLastAction())
      .then(updateCache);
  };
})();

$(document).ready(function initScripts() {
  var game = null;
  var svg = d3.select('svg');

  // Poor man's updates
  // setInterval(run, 1500);
  run();

  function run() {
    pollGameState(game)
      .then(renderPlayers)
      .then(renderLobyControls)
      .then(renderCards)
    ;
  }

  function renderPlayers(actions) {
    typeof actions;
    var joins = actions.filter(util.effect('join'));
    var players = svg.selectAll('.player').data(joins, keyByID);

    players.enter()
      .append('rect').classed('player',true);
  };

  function renderLobyControls(actions) {
    // TODO stub.
  }


  function renderCards(actions) {
    // TODO stub.
  }
});
