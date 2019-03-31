$(document).on('ready turbolinks:load', function() {

  if (window.location.pathname != '/provider/settings') {
    return;
  }

  window.readURL = function(input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();
      reader.onload = function (e) {
        $('.user-image').attr('src', e.target.result);
      }
      reader.readAsDataURL(input.files[0]);
    }
  }

  $('.settings-menu .nav-item a.nav-link').on('click', function(ev) {
    var el = $(ev.target);
    var tab = $(el.attr('href'));
    tab.show().siblings().hide();
    tab.addClass('active')
    tab.siblings().removeClass('active');  
    el.parent().parent().find('a.nav-link').removeClass('active');
    el.addClass('active')
    el.parent().parent().find('li.nav-item').removeClass('active');
    el.parent().addClass('active');
  });


  $("#avatar_field").change(function(){
    readURL(this);
  });

  var tabName = window.location.hash;
  // reactivate last used tab
  if (tabName.length) {
    $('.settings-menu .nav-item a.nav-link[href="' + tabName + '"]').trigger('click');    
  }

});

