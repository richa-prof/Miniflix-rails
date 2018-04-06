function jwplayer_setup (hls_url, original_url, caption_data){
  jwplayer("flim_video").setup({
    sources: [{
        file: hls_url
      },{
        file: original_url
      }],
    autostart: true,
    allowscriptaccess: 'always',
    allownetworking: 'all',
    tracks: caption_data
  });
}

$(document).on("click", ".full-screen-play", function() {
  $(".player").removeClass('hide');
  jwplayer("flim_video").setFullscreen(true);
  jwplayer("flim_video").play(true);
});


$(document).on('webkitfullscreenchange mozfullscreenchange fullscreenchange MSFullscreenChange', function(el){

  var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen || document.msFullscreenElement;
  if (state != true){
    jwplayer("flim_video").pause(true);
    $(".player").addClass('hide');
  } else{
     jwplayer("flim_video").play(true);
  }
});

function jwplayer_setup_error(){
  jwplayer().on('setupError',function(er){
    $('.full-screen-play').removeClass('full-screen-play');
    $('#err-player').html('<div class="alert alert-danger alert-dismissible" style="margin-top: 12px;"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>'+ er.message +'</div>');
  });
}
