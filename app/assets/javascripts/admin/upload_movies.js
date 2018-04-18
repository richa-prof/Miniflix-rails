// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {

  videoSubmitButton = function() {
    return $('.video-submit-button');
  };

  s3InputBucketName = function() {
    console.log('>>>>> s3InputBucketName() called >>>>>');
    return $('#s3-input-bucket-name-container').data('s3-input-bucket');
  };

  bindClickEventOnVideoSubmitButton = function() {
    console.log('>>>>> invoked bindClickEventOnVideoSubmitButton >>>>>');

    videoSubmitButton().off('click').on('click', function() { // The button class passed into multipart_uploader_form (see "Getting Started")
      console.log('>>>>> Fired click event on `video-submit-button` >>>>>');

      new window.S3MP({
        bucket: s3InputBucketName(),

        fileInputElement: "#video_file",

        fileList: $("#video_file").get(0).files, // An array of files to be uploaded (see "Getting Started")

        onStart: function(upload) {
          console.log("File %d has started uploading", upload.key)
        },

        onComplete: function(upload) {
          var up_file = JSON.stringify(upload);
          console.log("upload --> "+up_file);
          console.log("File %d successfully uploaded", upload.key);
          $("#error_msg").hide();
          $("#success_msg").show();
          $("#success_msg").empty().append("video uploaded successfully.");
          window.location.href =  "/admin/movies/add_movie_details/"+upload.id;
        },

        onPause: function(key) {
          console.log("File %d has been paused", key)
        },

        onCancel: function(key) {
          console.log("File upload %d was canceled", key)
        },

        onError: function(err) {
          console.log("<<<<<< onError callback invoked :: error --> ", err);
          var er = JSON.stringify(err);
          console.log("There was an error" + er);
          $("#success_msg").hide();
          $("#progress-bar").hide();
          $("#error_msg").show();
          $("#error_msg").empty().append('Error : '+err.message);
        },

        onProgress: function(num, size, done, percent, speed) {
          var v_percent = parseFloat(percent).toFixed(2);
          $("#error_msg").hide();
          $("#success_msg").hide();
          $("#progress-bar").show();
          $("#v_u_progress_bar").css({'width': v_percent+'%'});
          $("#v_u_percent").empty().append(v_percent+'%');
          $("#on_progress").empty().append("File is "+v_percent+" percent and  done--> "+done);
          console.log("File %d is %f percent done (%f of %f total) and uploading at %s", num, v_percent, done, size, speed);
        }
      });
    });
  };

}) (jQuery);

var ready;

ready = function() {
  console.log('>>>>> invoked `ready` function >>>>>');

  $("#video_file").addClass('form-control');

  if (videoSubmitButton().length) {
    bindClickEventOnVideoSubmitButton();
  }
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
