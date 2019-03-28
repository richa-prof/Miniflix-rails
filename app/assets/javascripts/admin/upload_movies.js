// class 
function MiniflixVideoUploader() {
  var self = this;
  self.init();
}


MiniflixVideoUploader.prototype.videoSubmitButton = function() {
  return $('.video-submit-button');
};

MiniflixVideoUploader.prototype.movieTrailerSubmitButton = function() {
  return $('.movie-trailer-submit-btn');
};

MiniflixVideoUploader.prototype.s3InputBucketName = function() {
  console.log('>>>>> s3InputBucketName() called >>>>>');
  return $('#s3-input-bucket-name-container').data('s3-input-bucket');
};

MiniflixVideoUploader.prototype.bindOnMovieSubmit = function() {
  var self = this;
  console.log('>>>>> invoked bindOnMovieSubmit >>>>>');

  self.videoSubmitButton().off('click').on('click', function() { // The button class passed into multipart_uploader_form (see "Getting Started")
    console.log('>>>>> Fired click event on `video-submit-button` >>>>>');

    new window.S3MP({
      bucket: self.s3InputBucketName(),
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
        var kind = $('#s3-input-bucket-name-container').data('kind'); // movie or episode
        window.location.href =  "/admin/" + kind + "s/upload_movie_trailer/" + upload.id + '?kind=' + kind;
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

MiniflixVideoUploader.prototype.bindOnMovieTrailerSubmit = function() {
  var self = this;
  console.log('>>>>> invoked bindOnMovieTrailerSubmit >>>>>');

  self.movieTrailerSubmitButton().off('click').on('click', function() { // The button class passed into multipart_uploader_form (see "Getting Started")
    console.log('>>>>> Fired click event on `movie-trailer-submit-btn` >>>>>');

    new window.S3MP({
      bucket: self.s3InputBucketName(),
      fileInputElement: "#trailer_video_file",
      fileList: $("#trailer_video_file").get(0).files, // An array of files to be uploaded (see "Getting Started")

      onStart: function(upload) {
        console.log("File %d has started uploading", upload.key)
      },

      onComplete: function(upload) {
        var up_file = JSON.stringify(upload);
        console.log("upload --> " + up_file);
        console.log("File %d successfully uploaded", upload.key);
        $("#error_msg").hide();
        $("#success_msg").show();
        $("#success_msg").empty().append("video uploaded successfully.");

        var is_edit_page = $('#movie-id-container').data('is-edit-mode');
        var ajaxTargetUrl = $('#movie-id-container').data('success-path');

        $.ajax({
          type: 'POST',
          data: { upload_id: upload.id,
                  movie_id: $('#movie-id-container').data('movie-id') },

          url: ajaxTargetUrl,

          success: function(response) {
            console.log(response.status);
            if (is_edit_page || is_edit_page == 'true') {
              $('.movie-trailer-submit-btn').attr("disabled", "disabled");
            } else {
              window.location.href =  "/admin/movies/add_movie_details/"+upload.id;
            }
          },
          error:function (xhr, ajaxOptions, thrownError) {
            console.log(thrownError);
          }
        });

      },

      onPause: function(key) {
        console.log("File %d has been paused", key)
      },

      onCancel: function(key) {
        console.log("File upload %d was cancelled", key)
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



MiniflixVideoUploader.prototype.init = function() {
  var self = this;
  console.log('>>>>> MiniflixVideoUploader -> init  >>>>>');
  $("#video_file").addClass('form-control');
  $("#trailer_video_file").addClass('form-control');
  if (self.videoSubmitButton().length) {
    self.bindOnMovieSubmit();
  }
  if (self.movieTrailerSubmitButton().length) {
    self.bindOnMovieTrailerSubmit();
  }
};



$(document).on(' ready turbolinks:load', function() {
  console.log('>>>>> creating MiniflixVideoUploader >>>>>');
  new MiniflixVideoUploader();
});
