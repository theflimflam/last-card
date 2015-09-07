/* global $, Util */
window.Resources = (function() {
  // TODO factor out??
  var pollActions = (function setupPollActions() {
    var state = {};
    var actionsSoFar = [];

    function pollMethod(params) {
      return $.getJSON(document.location + '/actions', params);
    }

    function updateState(actions) {
      if(actions.length > 0) {
        state.since = Util.last(actions).id;
      }
      return actions;
    }

    function concatWithActionsSoFar(actions) {
      actionsSoFar = actionsSoFar.concat(actions);
      return actionsSoFar;
    }

    return function pollActions() {
      return pollMethod(state)
        .then(updateState)
        .then(concatWithActionsSoFar)
      ;
    };
  })();

  function gameState(params) {
    return $.getJSON(document.location + '/state', params);
  }

  function signalReady() {
    return $.ajax({
      url:    document.location,
      method: 'put',
      data:   { ready: true }
    });
  }

  return {
    gameState:   gameState,
    actions:     pollActions,
    signalReady: signalReady
  };
})();
