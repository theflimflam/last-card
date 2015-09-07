/* global window */

window.Util = {
  last: function last(list) {
    return list.slice(-1)[0];
  },
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
