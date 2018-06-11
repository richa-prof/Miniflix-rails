// // Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
// (function ($) {

//   isEmptyValue = function(value) {
//     return (undefined === value || null === value || "" === value)
//   }

//   jwPlayerConfigContainer = function() {
//     return $('#jwPlayerConfigContainer');
//   };

//   jwplayer_setup = function() {
//     var jwPlayerConfig = jwPlayerConfigContainer();
//     var hlsUrl = jwPlayerConfig.data('hls-file');
//     var originalUrl = jwPlayerConfig.data('original-file');
//     var trailerFileUrl = jwPlayerConfig.data('trailer-file');

//     var sources = [{
//               file: hlsUrl
//             },{
//               file: originalUrl
//             }]

//     var videoObject = document.querySelector("div[data-embed-url='video-url1']");
//     videoObject.id = "player-1";
//     var newplayerInstance = window.jwplayer(videoObject);
//     window.player2 = newplayerInstance;
//     newplayerInstance.setup({
//       sources: sources,
//       allowscriptaccess: 'always',
//       allownetworking: 'all'
//     });

//     if (!isEmptyValue(trailerFileUrl)) {
//       var trailerSources = [{
//                 file: trailerFileUrl
//               }]

//       var trailerVideoObject = document.querySelector("div[data-embed-url='video-url2']");
//       trailerVideoObject.id = "player-2";
//       var newplayerInstance = window.jwplayer(trailerVideoObject);
//       window.player2 = newplayerInstance;
//       newplayerInstance.setup({
//         sources: trailerSources,
//         allowscriptaccess: 'always',
//         allownetworking: 'all'
//       });
//     }
//   };

//   jwplayer_setup_error = function() {
//     jwplayer().on('setupError',function(er){
//       $('.full-screen-play').removeClass('full-screen-play');

//       $('#err-player').html('<div class="alert alert-danger alert-dismissible" style="margin-top: 12px;"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>'+ er.message +'</div>');
//     });
//   };

//   bindChangeEventOnBrowserScreens = function() {
//     $(document).on('webkitfullscreenchange mozfullscreenchange fullscreenchange MSFullscreenChange', function(el){

//       var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen || document.msFullscreenElement;
//       if (state != true){
//         jwplayer("flim_video").pause(true);
//         $(".player").addClass('hide');
//       } else{
//         jwplayer("flim_video").play(true);
//       }
//     });
//   };

// }) (jQuery);

// var ready;

// ready = function() {
//   jwplayer.key = jwPlayerConfigContainer().data('jwplayer-key');

//   if (jwPlayerConfigContainer().length) {
//     bindChangeEventOnBrowserScreens();
//     jwplayer_setup();
//     jwplayer_setup_error();
//   }
// };

// $(document).ready(ready);
// $(document).on('turbolinks:load', ready);
