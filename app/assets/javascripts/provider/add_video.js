  $(document).on('ready turbolinks:load', function() {

    // alt. way - analize body[data-page]
    if (['/provider/serials/add_episode', '/provider/movies/add_video'].indexOf(window.location.pathname) < 0) {
      return false;
    }

    window.mfxObjects = window.mfxObjects || {};

    // class 
    function MiniflixFileSelect(selector) {
      var self = this;
      self.bid = btoa(selector);
      self.uploadZone = $(selector);
      if (window.mfxObjects['MiniflixFileSelect_' + self.bid]) {
         console.log('skipping init of MiniflixFileSelect for selector ' + selector);
         return false; // avoid init errors with Turbolinks
      }
      self.init();
      console.log('--- MiniflixFileSelect init passed, with selector: ' + selector + ' ----');
    }

    MiniflixFileSelect.prototype.init = function() {
      var self = this;
      self.uploadZone.on('dragover', self.handleDragOver);
      self.uploadZone.on('drop', (ev) => self.handleFileDrop(ev));
      self.fileInputElement = self.uploadZone.find('input[type="file"]');
      self.fileInputElement.on('change', (ev) => self.handleFileSelect(ev));
      window.mfxObjects['MiniflixFileSelect_' + self.bid] = true;
    }

    MiniflixFileSelect.prototype.formatBytes = function(bytes) {
      if(bytes < 1024) return bytes + " bytes";
      else if(bytes < 1048576) return(bytes / 1024).toFixed(3) + " KB";
      else if(bytes < 1073741824) return(bytes / 1048576).toFixed(3) + " MB";
      else return(bytes / 1073741824).toFixed(3) + " GB";
    };

    MiniflixFileSelect.prototype.checkFileType = function(files) {
      var self = this;
      return self.files[0].type.indexOf('video/') > -1;
    }

    MiniflixFileSelect.prototype.setProgress = function(percent) {
      var self = this;
      self.loadBar = self.uploadZone.parent().find('.ldBar')[0].ldBar;
      self.loadBar.set(percent); 
    }

    MiniflixFileSelect.prototype.handleFileSelect = function(evt) {
      var self = this;
      var ev = evt || window.event;
      ev.stopPropagation();
      ev.preventDefault();
      self.files = ev.target.files;
      self.handleFiles(); // name size type
    }

    MiniflixFileSelect.prototype.handleFileDrop = function(evt) {
      var self = this;
      var dataTransfer = evt.originalEvent.dataTransfer;
      evt.stopPropagation();
      evt.preventDefault();
      self.files = dataTransfer.files;
      self.handleFiles();
      return false;
    }

    MiniflixFileSelect.prototype.handleFiles = function() {
      var self = this;
      console.log('files:', self.files);
      console.log('bid:', self.bid);
      if (!self.checkFileType()) {
        alert('Wrong file type! Please select video!');
        return false;
      }
      // if (!self.fileInputElement[0].files.length) {
      //   console.log('trying to attach file to form');
      //   self.fileInputElement[0].append('file',files[0]);
      // }
      var out = [];
      for (var i = 0, f; f = self.files[i]; i++) {
        out.push('<p><strong>', escape(f.name), '</strong></p>','<p>' + self.formatBytes(f.size) + '</p');
      }
      self.uploadZone.parent().find('.about-file').html(out.join(''));
      self.uploadZone.parent().find('.file-info').show();
      self.uploadZone.hide();
      self.setProgress(100);
      return false;

    }

  MiniflixFileSelect.prototype.handleDragOver = function(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    evt.originalEvent.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
  }

  var mfxTrailerSelector = new MiniflixFileSelect('#trailer_upload_wrapper .dropbox-advanced-upload');
  var mfxMovieSelector = new MiniflixFileSelect('#video_upload_wrapper .dropbox-advanced-upload');


  $('#upload_videos').on('click', function() {

  })


  // class for handling video upload to AWS S3
  function MiniflixVideoUploader(selector, files) {
    var self = this;
    self.files = files;
    self.wrapper = $(selector);
    self.bid = btoa(selector);
    if (window.mfxObjects['MiniflixVideoUploader_' + self.bid]) {
      console.log('skipping init of MiniflixVideoUploader');
      return false; 
    }
    self.init();
    window.mfxObjects['MiniflixVideoUploader_' + self.bid]= true;
  }


  MiniflixVideoUploader.prototype.videoSubmitButton = function() {
    return self.wrapper.find('.video-submit-button');
  };

  MiniflixVideoUploader.prototype.movieTrailerSubmitButton = function() {
    return self.wrapper.find('.movie-trailer-submit-btn');
  };

  MiniflixVideoUploader.prototype.s3InputBucketName = function() {
    // console.log('>>>>> s3InputBucketName() called >>>>>');
    return self.wrapper.find('#s3-input-bucket-name-container').data('s3-input-bucket');
  };

  MiniflixVideoUploader.prototype.bindOnMovieSubmit = function() {
    var self = this;
    console.log('>>>>> invoked bindOnMovieSubmit >>>>>');
    var ajaxTargetUrl = self.wrapper.find('.js-movie-paths').data('video-upload-success-path');
    console.log('ajaxTargetUrl:', ajaxTargetUrl);

    self.videoSubmitButton().off('click').on('click', (ev) => function(ev) { // The button class passed into multipart_uploader_form (see "Getting Started")
      var self = this;
      console.log('>>>>> Fired click event on `video-submit-button` >>>>>');

      new window.S3MP({
        bucket: self.s3InputBucketName(),
        fileInputElement: "#video_file",
        fileList: self.files, // An array of files to be uploaded (see "Getting Started")

        onStart: function(upload) {
          console.log("File %d has started uploading", upload.key)
        },

        onComplete: function(upload) {
          var up_file = JSON.stringify(upload);
          console.log("video upload --> " + up_file);
          console.log("Video file %d successfully uploaded", upload.key);
          self.wrapper.find("#error_msg").hide();
          self.wrapper.find("#success_msg").show();
          self.wrapper.find("#success_msg").empty().append("video uploaded successfully.");
          var kind = self.wrapper.find('#s3-input-bucket-name-container').data('kind'); // movie or episode
          var urlPrefix = ajaxTargetUrl || "/admin/" + kind + "s/upload_movie_trailer/";
          //window.location.href =
          Turbolinks.visit(urlPrefix + upload.id + '?kind=' + kind);
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
          self.wrapper.find("#success_msg").hide();
          self.wrapper.find("#progress-bar").hide();
          self.wrapper.find("#error_msg").show();
          self.wrapper.find("#error_msg").empty().append('Error : '+err.message);
        },

        onProgress: function(num, size, done, percent, speed) {
          var v_percent = parseFloat(percent).toFixed(2);
          self.wrapper.find("#error_msg").hide();
          self.wrapper.find("#success_msg").hide();
          // $("#progress-bar").show();
          // $("#v_u_progress_bar").css({'width': v_percent+'%'});
          // $("#v_u_percent").empty().append(v_percent+'%');
          // $("#on_progress").empty().append("File is "+v_percent+" percent and  done--> "+done);
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
          console.log("trailer upload --> " + up_file);
          console.log("Trailer file %d successfully uploaded", upload.key);
          $("#error_msg").hide();
          $("#success_msg").show();
          $("#success_msg").empty().append("video uploaded successfully.");

          var is_edit_page = $('#movie-id-container').data('is-edit-mode');
          var ajaxTargetUrl = $('.js-movie-paths').data('trailer-upload-success-path');

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
                console.log('tp1');
                var redirectUrl = $('#movie-id-container').data('redirect-path') || "/admin/movies/add_movie_details/" + upload.id;
                Turbolinks.visit(redirectUrl);
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
    console.log('>>>>> MiniflixVideoUploader -> init !!!  >>>>>');
    self.wrapper.find("#video_file").addClass('form-control');
    self.wrapper.find("#trailer_video_file").addClass('form-control');
    if (self.videoSubmitButton().length) {
      self.bindOnMovieSubmit();
    }
    if (self.movieTrailerSubmitButton().length) {
      self.bindOnMovieTrailerSubmit();
    }
  };

  //new MiniflixVideoUploader(files);

});

$(document).on('turbolinks:before-cache', function () {
    console.warn('--- turbolinks:befor-cache fired ---');
});