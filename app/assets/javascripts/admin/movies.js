// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {

  jwPlayerConfigContainer = function() {
    return $('#jwPlayerConfigContainer');
  };

  jwplayer_setup = function(objType) {
    var jwPlayerConfig = jwPlayerConfigContainer();
    var hlsUrl = jwPlayerConfig.data('hls-file');
    var originalUrl = jwPlayerConfig.data('original-file');

    if (objType == 'trailer') {
      var sources = [{
                file: jwPlayerConfig.data('trailer-file')
              }]
    } else {
      var sources = [{
                file: hlsUrl
              },{
                file: originalUrl
              }]
    }

    jwplayer("flim_video").setup({
      sources: sources,
      autostart: true,
      allowscriptaccess: 'always',
      allownetworking: 'all'
    });
  };

  jwplayer_setup_error = function() {
    jwplayer().on('setupError',function(er){
      $('.full-screen-play').removeClass('full-screen-play');

      $('#err-player').html('<div class="alert alert-danger alert-dismissible" style="margin-top: 12px;"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>'+ er.message +'</div>');
    });
  };

  bindClickEventOnFullScreenPlayBtn = function() {
    $('.full-screen-play').off('click').on('click', function(event) {
      jwplayer_setup();
      jwplayer_setup_error();
      $(".player").removeClass('hide');
      jwplayer("flim_video").setFullscreen(true);
      jwplayer("flim_video").play(true);
    })
  };

  bindClickEventOnPlayTrailerBtn = function() {
    $('.play-movie-trailer-btn').off('click').on('click', function(event) {
      jwplayer_setup('trailer');
      jwplayer_setup_error('trailer');
      $(".player").removeClass('hide');
      jwplayer("flim_video").setFullscreen(true);
      jwplayer("flim_video").play(true);
    })
  };

  bindChangeEventOnBrowserScreens = function() {
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

}) (jQuery);

var ready;

ready = function() {
  jwplayer.key = jwPlayerConfigContainer().data('jwplayer-key');
  bindClickEventOnFullScreenPlayBtn();
  bindClickEventOnPlayTrailerBtn();
  bindChangeEventOnBrowserScreens();
  jwplayer_setup();
  jwplayer_setup_error();
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
