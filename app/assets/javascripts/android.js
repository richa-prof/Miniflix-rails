$(document).on("click", "#payment_method input[type='radio']",
  function(e) {
    set_payment_detail();
  }
);

function set_payment_detail(){
  if ($("#user_payment_method_payment_type_card:checked").val() == "Card") {
    $("#card_info").show();
    $("#card_info :input").removeAttr("disabled");
    check_stripe = 1;
  } else {
    $("#card_info").hide();
    $("#card_info :input").attr("disabled", true);
    // $(".payment-errors").text('');
    check_stripe = 0;
  }
};

$(document).ready(function() {
  set_payment_detail();
  $("#payment_method").validate({
    rules: {
      "user_payment_method[card_number]": {
        required: true,
        creditcard: true,
        minlength: 13,
        maxlength: 16
      },
      "user_payment_method[card_CVC]": {
        required: true,
        minlength: 3,
        maxlength: 3
      },
      "new_email":{
        required: true,
        email: true
      }

    },
    messages: {
      "user_payment_method[card_number]": {
        required: "Enter your credit card number."
      },
      "user_payment_method[card_CVC]": {
        required: "Enter card CVC."
      },
      "new_email":{
        required: "enter valid email",
        email: "enter valid email format"
      }
    }
  });

});