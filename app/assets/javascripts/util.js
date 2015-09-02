/* global window */

window.util = {
  filterEffect: function filterEffect(interesting) {
    function isInteresting(item) {
      return item.effect === interesting;
    }

    return function filter(list) {
      return list.filter(isInteresting);
    };
  },
  parameter: function parameter(parameter) {
    return function lookup(object) {
      return object[parameter];
    };
  }
};
