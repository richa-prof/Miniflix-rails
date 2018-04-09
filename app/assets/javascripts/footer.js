// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {

  contactNumInputField = function() {
    return $("#contact_number");
  };

  initiateIntlTelInputOnContactNumberField = function() {
    contactNumInputField().intlTelInput({
      autoPlaceholder: "polite",
      customPlaceholder: null,
      autoHideDialCode: false,
      nationalMode: false
    });
  };

  bindClickEventOnSendDownloadBtn = function() {
    var sendDownloadBtnObj = $('.send_dl_btn');
    var contactNumInputFieldObj = contactNumInputField();

    sendDownloadBtnObj.off("click").on("click", function(event) {
      var isValid = contactNumInputFieldObj.intlTelInput("isValidNumber");
      var intlNumber = contactNumInputFieldObj.intlTelInput("getNumber");

      if (isValid) {
        var ajaxTargetUrl = contactNumInputFieldObj.data('target-url');

        $.ajax({
          type: "GET",
          data: { number: intlNumber },
          url: ajaxTargetUrl,

          success: function(response) { 
            console.log(response.status);

            PNotify.removeAll();

            var notiTitle = ((response.status == "success") ? "Success!" : "Fail!");

            new PNotify({
              title: notiTitle,
              text: response.message,
              type: response.status,
              buttons: {
                sticker: false
              }
            });
          },
          error:function (xhr, ajaxOptions, thrownError) {
            console.log(thrownError);
          }
        });
      } else {

        var message = (intlNumber != "") ? "Entered number is invalid" : "Please enter contact number"

        PNotify.removeAll();

        new PNotify({
          title: "invalid number",
          text: message,
          type: "Fail",
          buttons: {
            sticker: false
          }
        });
      }
    });
  };

}) (jQuery);

var ready;

ready = function() {
  initiateIntlTelInputOnContactNumberField();
  bindClickEventOnSendDownloadBtn();
};

$(document).ready(ready);
