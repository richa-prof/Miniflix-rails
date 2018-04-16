// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {

  fileFields = function() {
    return $(".uploadfile-field .form-control");
  };

  bindChangeEventOnFileFields = function() {
    fileFields().change(function(){
      var fileFieldVal = $(this).val().replace(/C:\\fakepath\\/i, '');
      var targetField = $(this).closest(".upload-file-all").find(".targetFileField");
      targetField.val(fileFieldVal);
    })
  };

  adminStaffMemberForm = function() {
    return $("#frm_admin_staff_member");
  };

  adminSendReplyToVisitorForm = function() {
    return $('#frm_send_reply');
  };

  applyValidationToStaffMemberForm = function() {
    var formObject = adminStaffMemberForm();
    formObject.validate({
      rules: {
        "user[email]": { required: true,
                         email: true,
                         remote: formObject.data('check-email-path') }
      },
      messages: {
        "user[name]": {
          required: "Name can't be blank."
        },
        "user[email]": {
          required: "Please enter an email.",
          remote: "Email already exist."
        }
      }
    });
  };

  applyValidationToContactUserReplyForm = function() {
    adminSendReplyToVisitorForm().validate({
      rules: {
        "contact_user_reply[message]": { required: true }
      },

      messages: {
        "contact_user_reply[message]": {
          required: "Please enter a message for user."
        }
      }
    });
  };

}) (jQuery);

var ready;

ready = function() {
  if (fileFields().length) {
    bindChangeEventOnFileFields();
  }

  if ( adminStaffMemberForm().length ) {
    applyValidationToStaffMemberForm();
  }

  if ( adminSendReplyToVisitorForm().length ) {
    applyValidationToContactUserReplyForm();
  }
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
