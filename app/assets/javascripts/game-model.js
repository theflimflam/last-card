/* eslint-disable no-console */
(function() {
  function Game() {
    this.players = {};
    this.currState = {};
  }

  function setPlayerReady(id) {
    this.players[id].ready = true;
  }

  function addPlayer(player) {
    this.players[player.id] = player;
  }

  Game.prototype.players = function() { 
    return this.players;
  };

  function namesOf(newPlayers) {
    return newPlayers
      .map(function getName(player) { return player.name; })
      .join(', ')
    ;
  }

  Game.prototype.addPlayers = function addPlayers(newPlayers) {
    if ( newPlayers.length > 0 ) {
      console.log('Players: %s', namesOf(newPlayers));
      newPlayers.forEach.call(this, addPlayer);
    }
    return this;
  };

  Game.prototype.readyPlayers = function readyPlayers(playerIDs) {
    playerIDs.forEach.call(this, setPlayerReady);
    return this;
  };

  window.Game = Game;
})();
