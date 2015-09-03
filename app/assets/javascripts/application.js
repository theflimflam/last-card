/* global $, window, util, Game */
/* eslint-disable no-console */

//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function last(list) {
  return list.slice(-1)[0];
}

function getActionsJSON(params) {
  return $.getJSON(document.location + '/actions', params);
}

function getPlayerJSON(id) {
  return $.getJSON(document.location + '/players/' + id);
}

function signalReady() {
  return $.ajax({
    url:    document.location,
    method: 'put',
    data:   { ready: true }
  });
}

var pollGameState = (function() {
  function updateParams(actionsJSON) {
    if ( actionsJSON.length > 0 ) {
      this.since = last(actionsJSON).id;
    }
  }

  return function pollGameState(game) {
    var donePromise = getActionsJSON(game.currState);
    donePromise.then(updateParams.bind(game.currState));
    return donePromise;
  };
})();

$(document).ready(function initScripts() {
  var game = null;

  function run() {
    game = currentGame();
    if (game) {
      pollGameState(game).then(update);
    }
  }

  function currentGame() {
    var match = document.location.pathname.match(/^\/games\/\d+/);
    if (!match) {
      this.game = null;
    }
    else {
      this.game = this.game || new Game();
    }

    return this.game;
  }

  function update(actions) {
    updatePlayers(actions);
    updateGameStarted(actions);
  }

  function updatePlayers(actions) {
    // Join new players
    var addPlayers    = game.addPlayers.bind(game);
    var newIDs        = actions.filter(util.effect('join')).map(util.parameter('player_id'));
    var xhrPlayerJSON = newIDs.map(getPlayerJSON);
    Promise.all(xhrPlayerJSON).then(addPlayers);

    // Mark players as ready
    var readyIDs = actions.filter(util.effect('ready')).map(util.parameter('player_id'));
    game.readyPlayers(readyIDs);
  }

  function updateGameStarted(actions) {
    var setStarted = actions.filter(util.effect('start_game')).length > 0;
    if ( setStarted ) {
      game.started = true;
    }
  }

  // Poor man's updates
  setInterval(run, 1500);
  run();
});
