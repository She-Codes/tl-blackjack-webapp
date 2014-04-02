$(document).ready(function(){
  var flipCards = function() {
  // flip cards over
  $('.flip-container.animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $(this).addClass('turn-over');
  });

  setTimeout(function(){
    $('.delay-reveal').addClass('turn-over');
  }, 2500);
  
 
  $('.reveal').addClass('turn-over');

  // set a delay to give cards a chance to be dealt
  $('.total span').hide(0).delay(2600).show(0);
  };

  $(document).on('click', '.player-choice .hit', function(){
    $.ajax({
      type: 'POST',
      url: '/game/player/hit',
    }).done(function(msg){
      $('#game').replaceWith(msg);
      flipCards();
    });

    return false;
  });

  $(document).on('click', '.player-choice .stay', function(){
    $.ajax({
      type: 'POST',
      url: '/game/player/stay',
    }).done(function(msg){
      $('#game').replaceWith(msg);
      flipCards();
    });

    return false;
  });

  flipCards();

});