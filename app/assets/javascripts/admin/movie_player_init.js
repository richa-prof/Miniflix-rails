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

MiniflixVideoPlayer.prototype.jwPlayerSetup = function() {
  //console.log('>>>>> invoked `jsPlayerSetup` function >>>>>');
  var self = this;
  self.hlsUrl = self.config.data('hls-file');
  self.originalUrl = self.config.data('original-file');
  self.trailerFileUrl = self.config.data('trailer-file');
  var sources = [{
            file: self.hlsUrl
          }]
  //console.log('self: ', self.config.context);
  var videoObject =  self.parentContainer.find("div[data-embed-url='video-url']")[0];
  //console.log('videoObject', videoObject)
  var newplayerInstance = window.jwplayer(videoObject);
  window['player' + self.number] = newplayerInstance;
  newplayerInstance.setup({
    file: self.originalUrl
  });
  // handle trailers
  if (!self.isEmptyValue(self.trailerFileUrl)) {
    console.log('setup trailer player ');
    var trailerSources = [{
              file:self.trailerFileUrl
            }]
    var trailerVideoObject = self.parentContainer.find("div[data-embed-url='video-url2']")[0];
    //trailerVideoObject.id = "player-2";
    var trailerPlayerInstance = window.jwplayer(trailerVideoObject);
    window['player' + self.number] = trailerPlayerInstance;
    trailerPlayerInstance.setup({
      sources: trailerSources,
      allowscriptaccess: 'always',
      allownetworking: 'all'
    });
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
  //console.log('>>>>>> initializing player ' + self.number + ' >>>>>>>>>');
  // console.log('init element', el);
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

