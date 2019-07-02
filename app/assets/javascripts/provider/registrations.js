$(document).on('ready turbolinks:load', function() {
  
  $('.js-switch-section').on('click', function(ev) {
    var el = ev.target || window.event.target;
    var name = $(el).data('section');
    $('[rel="' + name + '"]').show().siblings().hide();
    return true;
  });
});
