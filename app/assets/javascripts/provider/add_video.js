$(document).on('turbolinks:load', function() {


   // alt. way - analize body[data-page]
  let invokePageList = ['/provider/serials/add_episode', '/provider/movies/add_video', '/provider/serials/add_trailer']
  if (invokePageList.indexOf(window.location.pathname) < 0) {
    return false;
  }

  window.mfxObjects = window.mfxObjects || {};
  window.files = window.files || [];
  window.lockTimer = null;

  window.videoCategories = window.videoCategories || ['trailer', 'video'];  // [video1, video2, video3, video4, ..] for episodes

  // class 
  function MiniflixFileSelect(selector) {
    var self = this;
    self.bid = btoa(selector);
    self.uploadZone = $(selector);
    if (window.mfxObjects['MiniflixFileSelect_' + self.bid]) {
      return false; // avoid init errors with Turbolinks
    }
    self.init();
    console.log('--- MiniflixFileSelect init passed, with selector: ' + selector + ' ----');
  }

  MiniflixFileSelect.prototype.init = function() {
    var self = this;
    self.uploadZone.on('dragover', self.handleDragOver);
    self.uploadZone.on('drop', (ev) => self.handleFileDrop(ev));
    self.uploadZone.parent().find('.rm-file-control').on('click', (ev) => self.handleFileRemove(ev));
    self.fileInputElement = self.uploadZone.find('input[type="file"]');
    self.fileInputElement.on('change', (ev) => self.handleFileSelect(ev));
    self.uploadZone.find('.dropbox-controls a').on('click', (ev) => self.clickFileSelect(ev));
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


  MiniflixFileSelect.prototype.handleFileRemove = function(evt) {
    var self = this;
    var ev = evt || window.event;
    ev.stopPropagation();
    ev.preventDefault();
    var fileName = self.files ? self.files[0].name : $(ev.target).parent().parent().prev().find('.js-file-name').html();
    choice = confirm("Are you sure you want to delete file named '" + fileName + "' ?");
    if(choice) {
      self.uploadZone.find('input')[0].value = '';
      self.uploadZone.parent().find('.file-info').hide();
      self.uploadZone.parent().find('.js-file-name').data('file-attached', false);
      self.uploadZone.show();
    }
    return false;
  }

  MiniflixFileSelect.prototype.clickFileSelect = function(evt) {
     var self = this;
     let ev = evt || window.event;
     let el = $(ev.target);
     //let inp = el.parent().parent().find('#video_file');
     //console.log('video input to click on', inp);
     //inp.click();
     self.fileInputElement.click();
     return false;
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
    var out = [];
    for (var i = 0, f; f = self.files[i]; i++) {
      out.push('<div><span class="js-file-name" data-file-attached="true"><strong>', escape(f.name), '</strong></span></div>','<div>' + self.formatBytes(f.size) + '</div>');
      window.files.push(f)      
    }
    self.uploadZone.parent().find('.about-file').html(out.join(''));
    self.uploadZone.parent().find('.file-info').show();
    self.uploadZone.hide();
    return false;
  }

  MiniflixFileSelect.prototype.handleDragOver = function(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    evt.originalEvent.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
  }

// ---------------- create object  -----------------
  for(i=0; i < window.videoCategories.length; i++) {
    new MiniflixFileSelect('#' + window.videoCategories[i] + '_upload_wrapper .dropbox-advanced-upload'); 
  }

  $('#upload_videos').on('click', function(evt) {
      if (window.lockTimer) {
        return false;
      }
      window.lockTimer = 1;
      var evt = evt || window.event;
      evt.stopPropagation();
      evt.preventDefault();

     // using recursion for handling dynamic list of videos!
      function submitVideos(url) {
        console.log('submitVideos', url);
        console.log(window.videoCategories, window.videoCategories.length);
        if (!window.videoCategories.length) {
          window.lockTimer = null;
          console.log('returning url from submitVideos', url);
          return url;
        }
        let category = window.videoCategories.shift();
        console.log('creating uploader for ',category);
        let uploader = new MiniflixVideosUploader('.js-provider-video-upload-wrapper', category); //  trailer
        uploader.submit().then((url) => {
          let finalURL = submitVideos(url);
          console.log('continue with', finalURL);
          // the last video uploader should return redirect url via promise
          if (finalURL && finalURL.length > 5) {
            console.log('redirect to :', finalURL);
            Turbolinks.visit(finalURL);
          } else {
            return finalURL;
          }
          console.log('finish');
        }).catch((reason) => {
           console.error('Promise to upload movie rejected with reason: ', reason);
        });
      };

      let url = submitVideos('go');
      return false;
  })



  $('#add_new_episode').on('click', function(evt) {
      if (window.lockTimer) {
        return false; 
      }
      window.lockTimer = 1;
      var evt = evt || window.event;
      evt.stopPropagation();
      evt.preventDefault();
      let lastFile = $('.js-videos .js-file-name:last');
      console.log(lastFile);
      let lastFileAttached = lastFile.data('file-attached') == true;
      // do not allow addition of few empty boxes for file upload
      if (lastFileAttached || !lastFile.length) {
        let counter = window.files ? window.files + 1 : 1
        $('#episodes_wrapper').append($('.js-episode-template').html());
        new MiniflixFileSelect('#episode_upload_wrapper:last .dropbox-advanced-upload'); 
        // $('#episodes_wrapper').find('a.js-video-browse:last').on('click', (ev) => self.clickFileSelect(ev));
      } else {
        console.warn('skipping adding box for uploading video - use previous one!');
      }
      window.lockTimer = null;
      return false;
  });

  $('#season_id').on('change', function(ev) {
    var evt = evt || window.event;
    var sid = evt.target.value;
    var setSeasonURL = $('.js-movie-paths').data('select-season-url');
     $.ajax({
      type: 'POST',
      data: {season_id: sid},
      url: setSeasonURL,
      success: function(response) {
        console.log('set season id response ', response);
      },
      error:function (xhr, ajaxOptions, thrownError) {
        console.error('error',thrownError);
      }
    });
  })

  // class for handling videos upload to AWS S3
  function MiniflixVideosUploader(selector, category) {
    var self = this;
    self.wrapper = $(selector);
    self.category = category;
    self.uploadWrapper = $('#' + category + '_upload_wrapper');
    console.log('uploadWrapper:', self.uploadWrapper);
    self.bid = btoa(selector + category);
    if (window.mfxObjects['MiniflixVideosUploader_' + self.bid]) {
      console.log('skipping init of MiniflixVideosUploader');
      return false; 
    }
    self.init();
    window.mfxObjects['MiniflixVideosUploader_' + self.bid]= true;
    //     return (async() => {self.submit(); })();
  }

  MiniflixVideosUploader.prototype.init = function() {
    var self = this;
    self.errors = [];
    // self.wrapper.find("#video_file").addClass('form-control');
    // self.wrapper.find("#trailer_video_file").addClass('form-control');
    self.myLoadBar = new ldBar('#' + self.category + '_upload_wrapper .ldBar');
    self.inputName = (self.category == 'trailer') ? '#trailer_video_file' : '#' + self.category + '_file';
    self.files = $(self.inputName)[0].files;
    console.log('--- MiniflixVideosUploader -> init ---');
  };

  MiniflixVideosUploader.prototype.setProgress = function(percent) {
    var self = this;
    self.myLoadBar.set(percent, true); 
  }

  MiniflixVideosUploader.prototype.s3InputBucketName = function() {
    var self = this;
    return $('#s3-input-bucket-name-container').data('s3-input-bucket');
  };

  MiniflixVideosUploader.prototype.kind = function() {
    var self = this;
    return $('#s3-input-bucket-name-container').data('kind');
  };

  MiniflixVideosUploader.prototype.submit = function() {
    var self = this;

    return new Promise((resolve, reject) => {
      new window.S3MP({
        bucket: self.s3InputBucketName(),
        fileInputElement: self.inputName,  // check + fixme !  '.file-upload input[type="file"]''
        fileList: self.files, // An array of files to be uploaded (see "Getting Started")

        onStart: function(upload) {
          self.uploadWrapper.find('.file-read-progress').show();
          self.uploadWrapper.find('.video-icon').hide();
          console.log("File %d has started uploading", upload.key)
        },

        onComplete: function(upload) {
          var up_file = JSON.stringify(upload);
          self.setProgress(100);
          self.wrapper.find("#error_msg").hide();
          $('.sys-message').html('<div id="flash_success" class="success"></div>')
          var kind = self.kind(); // movie or episode or serial
          if (self.category == 'trailer') {
            console.log("trailer upload --> " + up_file);
            //console.log("Trailer file %d successfully uploaded", upload.key);
            $(".sys-message .success").append("Trailer for movie has been uploaded successfully.");
            var is_edit_page = $('#movie-id-container').data('is-edit-mode');
            var postProcessUrl = $('.js-movie-paths').data('trailer-upload-success-path');
            var data = { upload_id: upload.id, kind: kind };
            data[kind + '_id'] = $('#movie-id-container').data('movie-id');
            console.log('posting data:', data);
            $.ajax({
              type: 'POST',
              data: data,
              url: postProcessUrl,
              success: function(response) {
                if (is_edit_page || is_edit_page == 'true') {
                  //$('.movie-trailer-submit-btn').attr("disabled", "disabled");
                } 
                var redirectUrl = $('#movie-id-container').data('redirect-path') ;
                console.log('resolve ', redirectUrl);
                resolve(redirectUrl);
              },
              error:function (xhr, ajaxOptions, thrownError) {
                console.error('error',thrownError);
                reject('bad');
              }
            });
          } else {
            console.log("video upload --> " + up_file);
            console.log("Video file %d successfully uploaded", upload.key);
            $(".sys-message .success").append("Video has been uploaded successfully.");
            let nextPageURL = $('.js-movie-paths').data('next-stage-path');
            console.log('resolve ', nextPageURL);
            resolve(nextPageURL);
          }
          //Turbolinks.visit(urlPrefix + upload.id + '?kind=' + kind);
          // http://admin.lvh.me:3001/admin/episodes/new?serial_id=37&season_id=31233737
          // <div class="js-movie-paths" style="display: none;" data-video-upload-success-path="/admin/movies/upload_movie_trailer/"></div>
        },

        onPause: function(key) {
          console.log("File %d has been paused", key)
        },

        onCancel: function(key) {
          console.log("File upload %d was canceled", key);
          reject('bad');
        },

        onError: function(err) {
          console.error("<<<<<< onError callback invoked :: error --> ", err);
          let er = JSON.stringify(err);
          console.error("There was an error" + er);
          self.wrapper.find("#success_msg").hide();
          self.wrapper.find("#progress-bar").hide();
          self.wrapper.find("#error_msg").show();
          self.wrapper.find("#error_msg").empty().append('Error : '+err.message);
          reject('bad');
        },

        onProgress: function(num, size, done, percent, speed) {
          let v_percent = parseFloat(percent).toFixed(0);
          self.wrapper.find("#error_msg").hide();
          self.wrapper.find("#success_msg").hide();
          self.setProgress(parseInt(v_percent));
          // $("#progress-bar").show();
          // $("#v_u_progress_bar").css({'width': v_percent+'%'});
          // $("#v_u_percent").empty().append(v_percent+'%');
          // $("#on_progress").empty().append("File is "+v_percent+" percent and  done--> "+done);
          //console.log("File %s is %d percent done (%f of %f total) and uploading at %s bytes/s", window.files[num], v_percent, done, size, speed);
        }
      });

    });
  };

});

$(document).on('turbolinks:before-cache', function () {
    console.warn('--- turbolinks:befor-cache fired ---');
});