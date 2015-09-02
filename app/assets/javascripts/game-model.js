/* eslint-disable no-console */
function Game() {
  this.players = [];
}

Game.prototype.players = function() { 
  return this.players;
};

var playerName = function(player) {
  return player.name;
};

Game.prototype.addPlayers = function addPlayers(players) {
  if ( players.length > 0 ) {
    console.log('New players %s', players.map(playerName).join(' '));
    this.players = this.players.concat(players);
  }
  return this;
};
