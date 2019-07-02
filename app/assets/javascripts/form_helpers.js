// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/

var initValidators = function() {

  fileFields = function() {
    return $(".uploadfile-field .form-control");
  };

  bindChangeEventOnFileFields = function() {
    fileFields().change(function() {
      var fileFieldVal = $(this)
        .val()
        .replace(/C:\\fakepath\\/i, "");
      var targetField = $(this)
        .closest(".upload-file-all")
        .find(".targetFileField");
      targetField.val(fileFieldVal);
    });
  };

//  only for provider UI 
  if (window.location.pathname.indexOf('/provider/') > -1) {
    window.previewImageForInput = function(input) {
      if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(ev) {
          var wrapper = $(input).parent().find('img');
          wrapper.attr('src', ev.target.result);
        }
        reader.readAsDataURL(input.files[0]);
      }
    }
  }

  bindChangeEventOnMovieThumbnailFileFields = function() {
    $(".movie-thumbnail-file-field")
      .off("change")
      .on("change", function(event) {
        var fileFieldId = $(this).attr("id");
        validFile(fileFieldId);
        if (window.location.pathname.indexOf('/provider/') > -1) {
          previewImageForInput(this); 
        }
        return false;
      });
  };

  bindClickEventOnMovieThumbnailFileFieldWrappers = function() {
    $(".movie-thumbnail-file-field-wrapper")
      .off("click")
      .on("click", function(event) {
        var targetObj = $(this).siblings(".movie-thumbnail-file-field");
        targetObj.click();
        return false;
      });
  };

  adminStaffMemberForm = function() {
    return $("#frm_admin_staff_member");
  };

  adminSendReplyToVisitorForm = function() {
    return $("#frm_send_reply");
  };

  applyValidationToStaffMemberForm = function() {
    var formObject = adminStaffMemberForm();
    formObject.validate({
      rules: {
        "user[email]": {
          required: true,
          email: true,
          remote: formObject.data("check-email-path")
        }
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
      ignore: [],
      rules: {
        "contact_user_reply[message]": {
          required: function() {
            CKEDITOR.instances.contact_user_reply_message.updateElement();
          }
        }
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
        "genre[name]": {
          required: true,
          remote: formObject.data("check-name-url")
        },
        "genre[color]": { required: true }
      },

      messages: {
        "genre[name]": {
          required: "Please enter an genre name.",
          remote: "Genre name already exist."
        },
        "genre[color]": {
          required: "Please enter a color"
        }
      }
    });
  };

  adminBackgroundImageForm = function() {
    return $("#new_background_image");
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

  adminAddMovieDetailsForm = function() {
    return $("#frm_admin_movie.add_movie_details_frm");
  };

  adminMovieEditForm = function() {
    return $(".edit_movie_frm");
  };

  adminMovieFormValidationRules = function() {
    var rulesMap = {
      "movie[name]": { required: true },
      "movie[title]": { required: true },
      "movie[description]": { required: true },
      "movie[admin_genre_id]": { required: true },
      "movie[video_type]": { required: true },
      "movie[video_size]": { required: true },
      "movie[video_duration]": { required: true },
      "movie[video_format]": { required: true },
      "movie[directed_by]": { required: true },
      "movie[released_date]": { required: true },
      "movie[language]": { required: true },
      "movie[posted_date]": { required: true },
      "movie[star_cast]": { required: true },
      "movie[actors]": { required: true }
    };

    return rulesMap;
  };

  adminMovieFormValidationMessages = function() {
    var messagesMap = {
      "movie[name]": { required: "Please enter a movie name." },
      "movie[title]": { required: "Please enter a movie title." },
      "movie[description]": { required: "Please enter a movie description." },
      "movie[admin_genre_id]": { required: "Please select genre type." },
      "movie[video_type]": { required: "Please enter a video type." },
      "movie[video_size]": { required: "Please enter a video size." },
      "movie[video_duration]": { required: "Please enter a video duration." },
      "movie[video_format]": { required: "Please enter a video format." },
      "movie[directed_by]": { required: "Please enter a directer name." },
      "movie[released_date]": { required: "Please select a released date." },
      "movie[language]": { required: "Please enter a language." },
      "movie[posted_date]": { required: "Please select a posted date." },
      "movie[star_cast]": { required: "Please enter a star cast." },
      "movie[actors]": { required: "Please enter an actor." }
    };
    return messagesMap;
  };

  adminMovieThumbnailValidationRules = function() {
    var rulesMap = {
      "movie_thumbnail[movie_screenshot_1]": { required: true },
      "movie_thumbnail[movie_screenshot_2]": { required: true },
      "movie_thumbnail[movie_screenshot_3]": { required: true }
    };
    return rulesMap;
  };

  adminMovieThumbnailValidationMessages = function() {
    var messagesMap = {
      "movie_thumbnail[movie_screenshot_1]": {
        required: "Please upload movie thumbnail."
      },
      "movie_thumbnail[movie_screenshot_2]": {
        required: "Please upload movie thumbnail."
      },
      "movie_thumbnail[movie_screenshot_3]": {
        required: "Please upload movie thumbnail."
      }
    };

    return messagesMap;
  };

  adminMovieAndThumbnailValidationRulesMap = function() {
    var rules1 = adminMovieFormValidationRules();
    var rules2 = adminMovieThumbnailValidationRules();
    return $.extend(rules1, rules2);
  };

  adminMovieAndThumbnailValidationMessagesMap = function() {
    var messages1 = adminMovieFormValidationMessages();
    var messages2 = adminMovieThumbnailValidationMessages();
    return $.extend(messages1, messages2);
  };

  applyValidationToAdminMovieForm = function() {
    var formObject = adminAddMovieDetailsForm();

    formObject.validate({
      rules: adminMovieAndThumbnailValidationRulesMap(),

      messages: adminMovieAndThumbnailValidationMessagesMap(),

      submitHandler: function(form) {
        // do other things for a valid form
        validate_thumbnails(form);
      }
    });
  };

  applyValidationToAdminMovieEditForm = function() {
    var formObject = adminMovieEditForm();
    formObject.validate({
      rules: adminMovieFormValidationRules(),
      messages: adminMovieFormValidationMessages(),
      submitHandler: function(form) {
        // do other things for a valid form
        validate_thumbnails(form);
      }
    });
  };

  open_file_upload = function(fileId) {
    $("#" + fileId).click();
  };

  validFile = function(fileId) {
    $("#" + fileId).valid();
  };

  enableDatePicker = function() {
    var dateInputFieldObjects = $(".date-picker");

    if (dateInputFieldObjects.length > 0) {
      dateInputFieldObjects.each(function() {
        $(this).datepicker({
          autoclose: true,
          startDate: "01.01.0001"
        });
      });
    }
  };

  enableICheckToCheckboxes = function() {
    var minimalCheckboxObjects = $(
      'input[type="checkbox"].minimal, input[type="radio"].minimal'
    );

    if (minimalCheckboxObjects.length > 0) {
      minimalCheckboxObjects.each(function() {
        $(this).iCheck({
          checkboxClass: "icheckbox_minimal-blue",
          radioClass: "iradio_minimal-blue"
        });
      });
    }
  };

  enableMaskToVideoDurationField = function() {
    if ($("#movie_video_duration").length) {
      $("#movie_video_duration").mask("00:00:00", { placeholder: "00:00:00" });
    }
  };

  bindKeypressEventOnSeasonsNumberField = function(e) {
    $("#serial_seasons_number").on("keypress", function(e) {
      var iKeyCode = e.which ? e.which : e.keyCode;
      if (iKeyCode != 46 && iKeyCode > 31 && (iKeyCode < 48 || iKeyCode > 57))
        return false;

      return true;
    });
  };

  enableDatePicker();
  enableICheckToCheckboxes();
  enableMaskToVideoDurationField();
  bindChangeEventOnMovieThumbnailFileFields();
  bindClickEventOnMovieThumbnailFileFieldWrappers();
  bindKeypressEventOnSeasonsNumberField();

  if (fileFields().length) {
    bindChangeEventOnFileFields();
  }

  if (adminStaffMemberForm().length) {
    applyValidationToStaffMemberForm();
  }

  if (adminSendReplyToVisitorForm().length) {
    applyValidationToContactUserReplyForm();
  }

  if (adminGenreForm().length) {
    applyValidationToAdminGenreForm();
  }

  if (adminBackgroundImageForm().length) {
    applyValidationToAdminBackgroundImageForm();
  }

  if (adminAddMovieDetailsForm().length) {
    applyValidationToAdminMovieForm();
  }

  if (adminMovieEditForm().length) {
    applyValidationToAdminMovieEditForm();
  }

};


// $(document).ready(ready);
$(document).on("ready turbolinks:load", initValidators);
