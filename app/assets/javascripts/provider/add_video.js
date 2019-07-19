$(document).on('ready turbolinks:load', function(ev) {

   // alt. way - analize body[data-page]
  var targetPages = ['/provider/serials/add_episode', '/provider/movies/add_video', '/provider/serials/add_trailer',  '/provider/episodes/add_video', '/provider/episodes/add_trailer']
  var basePath = window.location.pathname.split('/').slice(0,4).join('/');
  if (targetPages.indexOf(basePath) < 0) {
    console.warn('skip add_video js code init for page', window.location.pathname);
    return;
  }

  if ($('body').data('add-video-components')) {return; }
  $('body').data('add-video-components', 1);

  window.files = window.files || [];
  window.lockTimer = null;
  window.videoCategories = window.videoCategories || []; //['trailer', 'video'];

  function MiniflixFileSelect(selector) {
    var self = this;
    self.bid = btoa(selector);
    self.selector = selector;
    console.log('MiniflixFileSelect',self);
    self.uploadZone = $(selector);
    if (self.uploadZone.data('mfx-file-select') == self.bid) {
      //console.warn('skip MiniflixFileSelect init - already have an instance for specified container');
      return false; // avoid init errors with Turbolinks
    }
    self.uploadZone.data('mfx-file-select', self.bid);
    self.init();
    console.log('--- MiniflixFileSelect init passed, with selector: ' + selector + ' ----');
  }

  MiniflixFileSelect.prototype.init = function() {
    var self = this;
    console.log('bid:', self.bid);
    self.uploadZone.on('dragover', self.handleDragOver);
    self.videoCategoriesBkp = window.videoCategories;
    self.uploadZone.on('drop', (ev) => self.handleFileDrop(ev));
    self.uploadZone.parent().find('.rm-file-control').on('click', (ev) => self.handleFileRemove(ev));
    self.fileInputElement = self.uploadZone.find('input[type="file"]');
    self.fileInputElement.on('change', (ev) => self.handleFileSelect(ev));
    //console.log('uploadZone:', self.uploadZone);
    self.uploadZone.find('.dropbox-controls a').on('click', (ev) => self.clickFileSelect(ev));
    //$(self.selector + ' .dropbox-controls a').on('click', (ev) => self.clickFileSelect(ev));
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
    var fileName = self.files ? self.files[0].name : $(ev.target).parent().parent().prev().find('.js-file-name strong').html();
    choice = confirm("Are you sure you want to remove '" + fileName + "' file ?");
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
     //console.log('clickFileSelect');
      if (window.lockTimer) {
        return false;
      }
     window.lockTimer = 1;
     var ev = evt || window.event;
     self.fileInputElement.click();
     window.lockTimer = null;
     return false;
  }

  MiniflixFileSelect.prototype.handleFileSelect = function(evt) {
    var self = this;
    //console.log('handleFileSelect');
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
    self.fileInputElement[0].files = self.files;
    //console.log('files in input after drop ', self.fileInputElement[0].files, ' for input', self.fileInputElement);
    self.handleFiles();
    return false;
  }

  MiniflixFileSelect.prototype.handleFiles = function() {
    var self = this;
    if (!self.checkFileType()) {
      alert('Wrong file type! Please select video!');
      return false;
    }
    console.log('bid:', self.bid);
    window.videoCategories = self.videoCategoriesBkp;
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

// ---------------- create file selectors for video objects  -----------------
  for(i=0; i < window.videoCategories.length; i++) {
    new MiniflixFileSelect('.js-' + window.videoCategories[i] + '-upload-wrapper .dropbox-advanced-upload');
  }

  $('#upload_videos').on('click', function(evt) {
    if ($('.add_video_form').valid()) {
      $(this).text('Saving...');
      $(this).attr('disable', true);
      $(this).css('pointer-events', 'none');
      upload_video_fn(evt);
    }
  });

  function upload_video_fn(evt){
    if (window.lockTimer) {
      return false;
    }
    window.lockTimer = 1;
    var evt = evt || window.event;
    evt.stopPropagation();
    evt.preventDefault();

   // using recursion for handling dynamic list of videos!
    function submitVideos(url) {
      console.log('-- submitVideos', url);
      console.log(window.videoCategories, window.videoCategories.length);
      if (!window.videoCategories.length) {
        window.lockTimer = null;
        console.log('-- returning url from submitVideos', url);
        return url;
      }
      var category = window.videoCategories.shift();
      var selector = '.js-provider-video-upload-wrapper .js-' + category + '-upload-wrapper:first';
      var ms = new Date().getMilliseconds();
      $(selector).attr('id','video_' + ms);
      console.log('-- creating uploader for ', category, $(selector)[0].id);
      var uploader = new MiniflixVideosUploader('#' + $(selector)[0].id, category);
      $(selector).removeClass('js-' + category + '-upload-wrapper');
      uploader.submit().then((url) => {
        var finalURL = submitVideos(url);
        console.log('-- resolve URL', finalURL);
        // the last video uploader should return redirect url via promise
        if (finalURL && finalURL.length > 5) {
          console.log('-- redirect to :', finalURL);
          $('body').removeClass('busy');
          window.lockTimer = null;
          Turbolinks.visit(finalURL);
        } else {
          return finalURL;
        }
        console.log('-- finish');
      }).catch((reason) => {
         $('body').removeClass('busy');
         window.lockTimer = null;
         console.error('Promise to upload movie rejected with reason: ', reason);
      });
    };

    $('body').addClass('busy');
    var url = submitVideos('go');
    return false;
  }



  $('#add_new_episode').on('click', function(evt) {
      if (window.lockTimer) {
        return false;
      }
      window.lockTimer = 1;
      var evt = evt || window.event;
      evt.stopPropagation();
      evt.preventDefault();
      var lastFile = $('.js-videos .js-file-name:last');
      var lastFileAttached = lastFile.data('file-attached') == true;
      // do not allow addition of few empty boxes for file upload
      if (lastFileAttached || !lastFile.length) {
        var counter = window.files ? window.files + 1 : 1
        $('#new_episodes_wrapper').append($('.js-episode-template').html());
        console.log('init new MiniflixFileSelect component');
        window.videoCategories.push('episode');
        new MiniflixFileSelect('#new_episodes_wrapper .js-episode-upload-wrapper:last .dropbox-advanced-upload');
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
    self.category = category;
    self.selector = selector;
    self.uploadWrapper = $(selector);
    self.wrapper = self.uploadWrapper.find('.dropbox-advanced-upload');
    console.log('uploadWrapper:', self.uploadWrapper);
    self.bid = btoa(selector + category);
    if (self.wrapper.data('mfx-video-uploader') == self.bid) {
      console.warn('skipping MiniflixVideoUploader init - already have an instance');
      return false;
    }
    self.wrapper.data('mfx-video-uploader', self.bid);
    self.init();
  }

  MiniflixVideosUploader.prototype.init = function() {
    var self = this;
    self.errors = [];
    self.inputName = (self.category == 'trailer') ? '#trailer_video_file' : '#' + self.category + '_file';
    self.fileInput = self.uploadWrapper.find(self.inputName);
    self.files = self.fileInput[0].files;
    self.myLoadBar = new ldBar(self.selector + ' .ldBar');
    console.warn('--- MiniflixVideosUploader  init  passed ---');
  };

  MiniflixVideosUploader.prototype.setProgress = function(percent) {
    var self = this;
    self.myLoadBar.set(percent, true);
  }

  MiniflixVideosUploader.prototype.s3InputBucketName = function() {
    return $('#s3-input-bucket-name-container').data('s3-input-bucket');
  };

  MiniflixVideosUploader.prototype.kind = function() {
    return $('#s3-input-bucket-name-container').data('kind');
  };

  MiniflixVideosUploader.prototype.sysMessage = function (klass, msg) {
    $('.sys-message').html('<div id="flash_' + klass + '" class="' + klass + '"></div>')
    $(".sys-message ." + klass).html(msg);
  }

  MiniflixVideosUploader.prototype.submit = function() {
    var self = this;
    console.log('files:', self.files);

    // sample code to get video duration
    // var video = document.createElement('video');
    // video.preload = 'metadata';

    // video.onloadedmetadata = function() {
    //   console.log(this);
    //   window.URL.revokeObjectURL(video.src);
    //   var duration = video.duration;
    //   console.log("duration:", duration);
    // }
    // video.src = URL.createObjectURL(self.files[0]);


    return new Promise((resolve, reject) => {
      var redirectUrl = $('#movie-id-container').data('redirect-path') ;
      var nextPageURL = $('.js-movie-paths').data('next-stage-path');
      if (!self.files.length) {
        resolve(nextPageURL);
      }
      new window.S3MP({
        bucket: self.s3InputBucketName(),
        fileInputElement: self.inputName,
        fileList: self.files,

        onStart: function(upload) {
          self.uploadWrapper.removeClass('.js-' + self.category + '-upload-wrapper'); //important
          self.uploadWrapper.find('.file-read-progress').show();
          self.uploadWrapper.find('.video-icon').hide();
          console.log("File %d has started uploading", upload.key)
        },

        onComplete: function(upload) {
          var up_file = JSON.stringify(upload);
          self.setProgress(100);
          self.wrapper.find("#error_msg").hide();
          var kind = self.kind(); // movie or episode or serial
          if (self.category == 'trailer') {
            console.log("trailer upload --> " + up_file);
            //console.log("Trailer file %d successfully uploaded", upload.key);
            self.sysMessage('success', "Trailer for movie has been uploaded successfully.");
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
            console.log("Video file %d successfully uploaded", upload.key);
            self.sysMessage('success', "Video has been uploaded successfully.");
            var nextPageURL = $('.js-movie-paths').data('next-stage-path');
            resolve(nextPageURL);
          }
        },

        onPause: function(key) {
          console.log("File %d has been paused", key)
        },

        onCancel: function(key) {
          console.log("File upload %d was canceled", key);
          reject('bad');
        },

        onError: function(err) {
          var er = JSON.stringify(err);
          console.error("Error occured: " + er);
          self.sysMessage('error', err.message + ' for file "' + self.files[0].name);
          reject(err.message);
        },

        onProgress: function(num, size, done, percent, speed) {
          var v_percent = parseFloat(percent).toFixed(0);
          self.wrapper.find("#error_msg").hide();
          self.wrapper.find("#success_msg").hide();
          self.setProgress(parseInt(v_percent));
        }
      });

    });
  };

});

$(document).on('turbolinks:before-cache', function () {
    console.warn('--- turbolinks:before-cache fired ---');
});