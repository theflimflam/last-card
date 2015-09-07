/* global $, window */
window.CardDimensions = (function(){
  var $svg = $('svg');
  var height = Math.min($svg.height(), $svg.width()) / 8;
  var width = height * (100/150);

  return {
    height: parseInt(height, 10),
    width: parseInt(width)
  };
})();
