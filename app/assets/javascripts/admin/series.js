$(document).on('turbolinks:load', function() {

  $('select#season_id').on('change', function(ev) {
    var el = ev.target || window.event.target;
    var link = $('#new_episode_link a');
    var lhref = link.attr('href');
    if (lhref.indexOf('season_id') < 0 ) {
      link.attr('href', lhref + '&season_id=' + el.value);
    }
    if (el.value.length) {
      $('#season_errors').hide();
      $('#new_episode_link').show();
    } else {
      $('#season_errors').show();
      $('#new_episode_link').hide();
    }
    return true;
  });

});