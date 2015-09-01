/* global $  */
/* eslint-disable no-console */
$(document).ready(function() {
  var $ready = $('.state.ready').hide();
  var $game = $('.state.playing').hide();

  function show($that) {
    $('.state').hide();
    $that.show();
  }

  function waitTillGameStart() {
  }

  function toggleReady() {
    show($ready);

    setTimeout(waitTillGameStart, 2000);
  }

  function startGame() {
    show($game);
    window.ignition.start();
  }

  $('.state').not('.pending').hide();
  $('#toggle-ready').on('click', toggleReady);
});
