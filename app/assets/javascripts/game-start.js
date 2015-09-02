/* global $, window  */
/* eslint-disable no-console */
$(document).ready(function() {
  var $ready = $('.state.ready').hide();
  var $game = $('.state.playing').hide();

  function show($that) {
    $('.state').hide();
    $that.show();
  }

  function pollTillGameStart() {
    var interval = window.setInterval(updateActions, 1000);
    var params = {};

    function effect(interesting) {
      return function filterEffect(item) {
        return item.effect === interesting;
      };
    }

    function last(list) { return list.slice(-1)[0]; }

    function updateActions() {
      $.getJSON(document.location + '/actions', params).then(function(actions) {
        if ( actions.length === 0 ) {
          return;
        }

        params.since = last(actions).id;

        updatePlayers(actions.filter(effect('join')));
        var game_start = actions.filter(effect('game_start'));
      });
    }
  }

  var updatePlayers = (function() {
    var cache = [];

    function playerId(action) { return action.player_id; }

    return function updatePlayers(actions) {
      if ( actions.length === cache.length ) {
        return;
      }

      var playerList = actions.map(playerId).map(function(id) {
        $('<li>').text(id);
      });

      $('#players').html(players);
    }
  })();

  function toggleReady() {
    show($ready);
    $.ajax({
      // url: document.location,
      method: 'PUT',
      data: { ready: true },
      dataType: 'json'
    });
  }

  function startGame() {
    show($game);
    window.ignition.start();
  }

  $('.state').not('.pending').hide();
  $('#toggle-ready').on('click', toggleReady);

  pollTillGameStart();
});
