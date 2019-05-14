$(document).on('ready turbolinks:load', function() {  
  $("#new_provider_user").validate({
    rules: {
      "email": {required: true,email: true},
      "password": {required: true}
    },
    messages: {
      "email":{
        required: "Please enter an email address or username.",
      },
      "password": {
        required: "Please enter a password."
      }
    }
  });

  $('.password-icon').on('click', function(ev) {
    if (window.lock) { return false;}
    window.lock = true;
    let el = $('.password-icon');
    let inp = el.parent().find('.password-input');
    let tt = inp.attr('type');
    if (tt == 'password') {
      el.find('.js-eye-invisible').addClass('hidden');
      el.find('.js-eye-visible').removeClass('hidden');
      inp.attr('type', 'text');
    } else {
      el.find('.js-eye-visible').addClass('hidden');
      el.find('.js-eye-invisible').removeClass('hidden');
      inp.attr('type', 'password');
    }
    setTimeout(function(){window.lock = false;}, 100);
  });
});