// class 
function MiniflixVideoPlayer(cnt) {
  var self = this;
  //console.log('parentContainer for videos:', $(cnt));
  $(cnt).each(function(idx, el) {
    self.init(idx, el);
  });
}

MiniflixVideoPlayer.prototype.isEmptyValue = function(value) {
    return (undefined === value || null === value || "" === value)
  }

MiniflixVideoPlayer.prototype.configContainer = function() {
    var self = this;
    return self.parentContainer.find('.jwPlayerConfigContainer');
  };

MiniflixVideoPlayer.prototype.jwPlayerInit = function(container, type) {
  var self = this;
  var videoObject =  container.find("div[data-embed-url='video-url']")[0];
  var videoPlayerInstance = window.jwplayer(videoObject);
  self.hlsUrl = self.config.data('hls-file');
  self.originalUrl = self.config.data('original-file');
  self.trailerFileUrl = self.config.data('trailer-file');
  window['player' + self.number] = videoPlayerInstance;
  var opts = {};
  if (type != 'trailer') {
    opts ={
      file: self.originalUrl,
      sources: [{ file: self.hlsUrl }]
    };
  } else {
    opts = {
      sources: [{ file: self.trailerFileUrl }],
      allowscriptaccess: 'always',
      allownetworking: 'all'
    };
  }
  videoPlayerInstance.setup(opts);
}
MiniflixVideoPlayer.prototype.jwPlayerSetup = function() {
  //console.log('>>>>> invoked `jsPlayerSetup` function >>>>>');
  var self = this;
  self.jwPlayerInit(self.parentContainer, 'movie');
  // handle trailers
  if (!self.isEmptyValue(self.trailerFileUrl)) {
    console.log('setup trailer player ');
    //console.log('parent container:', self.parentContainer);
    self.jwPlayerInit(self.parentContainer, 'trailer');
  }
};

MiniflixVideoPlayer.prototype.jwPlayerSetupError = function() {
  jwplayer().on('setupError',function(er){
    $('.full-screen-play').removeClass('full-screen-play');
    $('#err-player').html('<div class="alert alert-danger alert-dismissible" style="margin-top: 12px;"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>'+ er.message +'</div>');
  });
};

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

MiniflixVideoPlayer.prototype.init = function(index, el) {
  var self = this;
  self.number = index + 1;
  if (window['player' + self.number]) {return false;}
  console.log('>>>>>> initializing player ' + self.number + ' >>>>>>>>>');
  console.log('init element', el);
  self.captionData = [];
  self.parentContainer = $(el);

  self.config = self.configContainer();
  jwplayer.key = self.config.data('jwplayer-key');
  // console.log('config:', self.config);
  if (self.config.length) {
    self.bindChangeEventOnBrowserScreens();
    self.jwPlayerSetup();
    self.jwPlayerSetupError();
  }
}

var ready = function() {
  console.log('>>>>> invoked `ready` function for jwPlayer >>>>>');
  new MiniflixVideoPlayer('.js-video-layer');
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);

