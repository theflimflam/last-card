/* global $, window, util, Game, Q */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

//////////////////////////////////////////
// Utility functions
function last(list) {
  return list.slice(-1)[0];
}

function getActionsJSON(params) {
  return $.getJSON(document.location + '/actions', params);
}

function getPlayerJSON(id) {
  return $.getJSON(document.location + '/players/' + id);
}

function lastID() {
  return last(this).id;
}

var pollGameState = (function() {
  var params = {};

  function updateParams(actionsJSON) {
    if ( actionsJSON.length > 0 ) {
      params.since = lastID.call(actionsJSON);
    }
  }

  return function pollGameState() {
    var donePromise = getActionsJSON(params);
    donePromise.then(updateParams);
    return donePromise;
  };
})();

//////////////////////////////////////////
// Game run loop wazzit
$(document).ready(function initScripts() {
  setInterval(run, 1000);

  var game = new Game();

  function run() {
    pollGameState()
      .then(update)
    ;
  }

  function update(actions) {
    updatePlayers(actions);

    // Game started?
    util.filterEffect('game_start');
    console.log('game started: %s', actions.length > 0);
  }

  function updatePlayers(actions) {
    var addPlayers  = game.addPlayers.bind(Game);
    var joinActions = util.filterEffect('join')(actions);
    var newIDs      = joinActions.map(util.parameter('player_id'));
    var xhrPromises = newIDs.map(getPlayerJSON);
    Promise.all(xhrPromises).then(addPlayers);
  }
});
