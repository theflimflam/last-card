/* global window */

window.util = {
  effect: function effect(interesting) {
    return function filterEffect(item) {
      return item.effect === interesting;
    };
  },
  parameter: function parameter(parameter) {
    return function lookup(object) {
      return object[parameter];
    };
  }
};
