/* eslint-disable no-console */
function Game() {
  this.players = [];
}

Game.prototype.players = function() { 
  return this.players;
};

Game.prototype.addPlayers = function addPlayers(players) {
  if ( players.length > 0 ) {
    console.log('New players %s', players.join(' '));
    this.players = this.players.concat(players);
  }
  return this;
};
