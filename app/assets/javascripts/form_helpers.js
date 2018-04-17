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

  adminGenreForm = function() {
    return $("#frm_admin_genre");
  };

  applyValidationToAdminGenreForm = function() {
    var formObject = adminGenreForm();

    formObject.validate({
      rules: {
        "genre[name]": { required: true,
                         remote: formObject.data('check-name-url') },
        "genre[color]": { required: true }
      },

      messages: {
        "genre[name]": {
          required: "Please enter an genre name.",
          remote: "Genre name already exist."
        },
        "genre[color]": {
          required: "Please enter a color",
        }
      }
    });
  };

  adminBackgroundImageForm = function() {
    return $('#new_background_image');
  };

  applyValidationToAdminBackgroundImageForm = function() {
    var formObject = adminBackgroundImageForm();

    formObject.validate({
      rules: {
        "background_image[image_file]": { required: true }
      },
      messages: {
        "background_image[image_file]": {
          required: "Please enter an Background."
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

  if ( adminGenreForm().length ) {
    applyValidationToAdminGenreForm();
  }

  if ( adminBackgroundImageForm().length ) {
    applyValidationToAdminBackgroundImageForm();
  }
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
