/* global $, window  */
/* eslint-disable no-console */
function processInput() {
}

$(document).ready(function initGame() {
  function run() {
    processInput();
    update();
    render();
  }

  var loop = window.setInterval(run, 1000);
});
