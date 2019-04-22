
$(document).on('ready turbolinks:load', function(ev) {
  
  window.mfxObjects = window.mfxObjects || {};

  // class 
  function MiniflixVideoPlayer(idx, el) {
    var self = this;
    self.bid = btoa(el.id);
    self.category = el.id.split('_')[0];
    if (window.mfxObjects['MiniflixVideoPlayer_' + self.bid]) {
      console.log('skipping MiniflixVideoPlayer init - already have an instance');
      return false; // avoid init errors with Turbolinks
    }
    self.init(idx, el);
    window.mfxObjects['MiniflixVideosPlayer_' + self.bid]= true;
  }

  MiniflixVideoPlayer.prototype.init = function(index, el) {
    var self = this;
    //self.number = index + 1;
    //if (window['player' + self.number]) {return false;}
    console.log('>>>>>> initializing player for ' + self.category + ' >>>>>>>>>');
    console.log('wrapper', el);
    self.captionData = [];
    self.wrapper = $(el);

    self.config = self.wrapper.find('.jwPlayerConfigContainer');
    jwplayer.key = self.config.data('jwplayer-key');
    // console.log('config:', self.config);
    if (self.config.length) {
      self.bindChangeEventOnBrowserScreens();
      self.jwPlayerInit();  //Setup();
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
    var videoObject =  self.wrapper.find("#" + self.category + "_embed_cnt")[0];  //div[data-embed-url='video-url']"); // [0]
    console.log('videoObject:', videoObject);
    console.log('jwPlayerInit called for ', self.category);
    var videoPlayerInstance = window.jwplayer(videoObject);
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
    console.log('jwPlayer options for ', self.category, opts)
    videoPlayerInstance.setup(opts);
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


  $('.js-video-layer').each(function(idx, el) {
    console.warn('----- setting up video player with jwPlayer on event ', ev.type);
    new MiniflixVideoPlayer(idx, el);
  });

});

