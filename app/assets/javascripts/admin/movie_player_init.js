
$(document).on('turbolinks:load', function(ev) {
  
  console.log('event:', ev.type);
  window.mfxObjects = window.mfxObjects || {};

  // class 
  function MiniflixVideoPlayer(idx, el) {
    var self = this;
    console.log(idx, el.id);
    self.bid = btoa(el.id);
    self.category = el.id.split('_')[0];
    if (window.mfxObjects['MiniflixVideoPlayer_' + self.bid]) {
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
        file: self.trailerFileUrl,
        sources: [{ file: self.trailerFileUrl }],
        allowscriptaccess: 'always',
        allownetworking: 'all'
      };
    }
    console.log('options for ', self.category, opts)
    videoPlayerInstance.setup(opts);
  }


  MiniflixVideoPlayer.prototype.jwPlayerSetupError = function() {
    jwplayer().on('setupError',function(er){
      $('.full-screen-play').removeClass('full-screen-play');
      //$('#err-player').html('<div class="alert alert-danger alert-dismissible" style="margin-top: 12px;"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>'+ er.message +'</div>');
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


  console.log('>>>>> invoked `ready` function for jwPlayer >>>>>');
  $('.js-video-layer').each(function(idx, el) {
    new MiniflixVideoPlayer(idx, el);
  });

});

