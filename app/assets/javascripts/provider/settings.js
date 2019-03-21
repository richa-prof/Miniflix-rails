$(document).on('ready turbolinks:load', function() {
  $('.settings-menu .nav-item a.nav-link').on('click', function(ev) {
    var el = $(ev.target);
    var tab = $(el.attr('rel'));
    tab.show().siblings().hide();
    tab.addClass('active')
    tab.siblings().removeClass('active');  
    console.log(el);
    el.parent().parent().find('a.nav-link').removeClass('active');
    el.addClass('active')
    el.parent().parent().find('li.nav-item').removeClass('active');
    el.parent().addClass('active');
  });

  $("#avatar_field").change(function(){
    readURL(this);
  });

});

window.readURL = function(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function (e) {
      $('.user-image').attr('src', e.target.result);
    }
    reader.readAsDataURL(input.files[0]);
  }
}
