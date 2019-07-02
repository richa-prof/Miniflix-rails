
$(document).on('ready turbolinks:load', function(ev) {
  
  // prevent double init
  if ($('body').data('mfx-video-players')) {return; } 
  $('body').data('mfx-video-players', 1);
  
  function MiniflixVideoPlayer(el) {
    var self = this;
    self.bid = btoa(el.id);
    self.category = el.id.split('_')[0];
    self.wrapper = $('#' + el.id);
    console.log('wrapper:', self.wrapper);
    // if ($(el).attr('data-mfx-video-player') == self.bid) {
    //   console.warn('skip MiniflixVideoPlayer init (already initialized) on event ', ev.type);
    //   return false;
    // }
    // $(el).attr('data-mfx-video-player', self.bid);
    self.init(el);
  }

  MiniflixVideoPlayer.prototype.init = function() {
    var self = this;
    self.captionData = [];
    self.config = self.wrapper.find('.jwPlayerConfigContainer');
    jwplayer.key = self.config.data('jwplayer-key');
    if (self.config.length) {
      self.bindChangeEventOnBrowserScreens();
      self.jwPlayerInit();
      self.jwPlayerSetupError();
    } else {
      console.error('no config found for player with category ', self.category);
      console.log(self.config);
    }
  }

  MiniflixVideoPlayer.prototype.isEmptyValue = function(value) {
    return (undefined === value || null === value || "" === value)
  }

  MiniflixVideoPlayer.prototype.jwPlayerInit = function() { //container, type) {
    var self = this;
    var videoObject = self.wrapper.find('.jw-player')  //"#" + self.category + "_embed_cnt");  
    console.log('videoObject:', videoObject);
    console.log('jwPlayerInit called for ', self.category);
    var videoPlayerInstance = window.jwplayer(videoObject[0]);
    self.hlsUrl = self.config.data('hls-file');
    console.log('hlsUrl', self.hlsUrl);
    self.originalFileUrl = self.config.data('original-file');
    self.trailerFileUrl = self.config.data('trailer-file');
    var opts;
    if (self.category != 'trailer') {
      opts = {
        file: self.originalFileUrl,
        sources: [{ file: self.hlsUrl || self.originalFileUrl }]
      };
    } else {
      opts = {
//      file: self.trailerFileUrl,
//      sources: [{ file: self.trailerFileUrl }],
        file: self.originalFileUrl,
        sources: [{ file: self.originalFileUrl }],
        allowscriptaccess: 'always',
        allownetworking: 'all'
      };
    }
    //console.log('jwPlayer options for ', self.category, opts)
    videoPlayerInstance.setup(opts);
    console.log('videoPlayerInstance', videoPlayerInstance.getContainer());
  }


  MiniflixVideoPlayer.prototype.jwPlayerSetupError = function() {
    jwplayer().on('setupError',function(er){
      $('.full-screen-play').removeClass('full-screen-play');
    });
  };

  // FIXME!
  MiniflixVideoPlayer.prototype.bindChangeEventOnBrowserScreens = function() {
    $(document).on('webkitfullscreenchange mozfullscreenchange fullscreenchange MSFullscreenChange', function(el){
      var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen || document.msFullscreenElement;
      if (state != true){
        jwplayer("flim_video").pause(true);
        $(".player").addClass('hide');
      } else{
        jwplayer("flim_video").play(true);
      }
    });
  };

  //console.log('>>>>> invoked `ready` function for jwPlayer >>>>>');
  $('.js-video-layer').each(function(idx, el) {
    console.warn('----- setting up video player with jwPlayer on event ', ev.type);
    new MiniflixVideoPlayer(el);
  });

});

