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
});