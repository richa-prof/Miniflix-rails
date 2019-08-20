$(document).on('ready turbolinks:load', function(ev) {
  setTimeout(function(e) {
    setVideoDuration();
  });
  // alt. way - analize body[data-page]
  var targetPages = [
   '/provider/serials/add_screenshots', '/provider/movies/add_screenshots', '/provider/serials/add_thumbnails', '/provider/movies/add_thumbnails',
   '/provider/episodes/add_screenshots', '/provider/episodes/add_thumbnails',
   '/admin/movies/add_movie_details', '/admin/movies/edit', '/admin/serials/edit'
  ];

  var basePath1 = window.location.pathname.split('/').slice(0,4).join('/');
  var bp2 = window.location.pathname.split('/');
  bp2.splice(3,1);
  basePath2 = bp2.join('/');

  // avoid double init
  if ((targetPages.indexOf(basePath1) < 0 && targetPages.indexOf(basePath2) < 0) || $('body').data('mfx-add-screenshots')) {
    console.warn('skip js code init related to adding screenshots/thumbnails for page', window.location.pathname);
    return;
  }

  $('body').data('mfx-add-screenshots', 1);

  console.log('-- init code related to adding screenshots/thumbnails on event ', ev.type);

  window.URL = window.URL || window.webkitURL;

  window.validate_thumbnails = function(form){
    var fileInput = $("#thumbnail_screenshot");
    var file = fileInput[0].files && fileInput[0].files[0];

    var fileInput640 = $("#thumbnail_640_screenshot");
    file640 = fileInput640[0].files && fileInput640[0].files[0];

    var fileInput800 = $("#thumbnail_800_screenshot");
    file800 = fileInput800[0].files && fileInput800[0].files[0];

    var error = false;

    var haveExistedImage = $('#thumbnail_screenshot').prev().find('img').attr('src').length > 10;
    var haveExistedImage640 = $('#thumbnail_640_screenshot').prev().find('img').attr('src').length > 10;
    var haveExistedImage800 = $('#thumbnail_800_screenshot').prev().find('img').attr('src').length > 10;

    if( file ) {
      var img = new Image();
      img.src = window.URL.createObjectURL( file );

      img.onload = function() {
        var width = img.naturalWidth,
          height = img.naturalHeight;

        window.URL.revokeObjectURL( img.src );

        if( width == 330 && height == 360 ) {
          // form.submit();
          $("#thumbnail_error").html("Please upload image with 330x360 size only").hide();
        }
        else {
            //fail
          $("#thumbnail_error").html("Please upload image with 330x360 size only").show();
          // $('.sys-message').html('<div id="flash_error" class="error">Please upload thumbnail of image size 330 x 360</div>');
          error = true;
        }
      };
    }
    else { //No file was input or browser doesn't support client side reading
      if (!haveExistedImage) {
        $("#thumbnail_error").html("Please upload thumbnail image").show();
        // $('.sys-message').html('<div id="flash_error" class="error">Please upload thumbnail of image size 330 x 360</div>');
      }
    }

    if( file640 ) {
      var img640 = new Image();
      img640.src = window.URL.createObjectURL( file640 );

      img640.onload = function() {
        var width = img640.naturalWidth,
          height = img640.naturalHeight;

        window.URL.revokeObjectURL( img640.src );

        if( width == 600 && height == 300 ) {
          // form.submit();
          $("#thumbnail_640_error").html("Please upload image with 600x300 size only").hide();
        }
        else {
            //fail
          console.log("invalid dimention==>",width,"--height-->",height)
          $("#thumbnail_640_error").html("Please upload image with 600x300 size only").show();
          // $('.sys-message').html('<div id="flash_error" class="error">Please upload thumbnail of image size 600 x 300</div>');
          error = true;
        }
      };
    }
    else { //No file was input or browser doesn't support client side reading
      if (!haveExistedImage640) {
        $("#thumbnail_640_error").html("Please upload thumbnail image").show();
        // $('.sys-message').html('<div id="flash_error" class="error">Please upload thumbnail of image size 600 x 300</div>');
        error = true;
      }
    }

    if( file800 ) {
      var img800 = new Image();
      img800.src = window.URL.createObjectURL( file800 );

      img800.onload = function() {
        var width = img800.naturalWidth,
          height = img800.naturalHeight;

        window.URL.revokeObjectURL( img800.src );

        if( width == 800 && height == 400 ) {
          // form.submit();
          $("#thumbnail_800_error").html("Please upload image with 800x400 size only").hide();
        }
        else {
            //fail
          console.log("invalid dimention==>",width,"--height-->",height)
          $("#thumbnail_800_error").html("Please upload image with 800x400 size only").show();
          // $('.sys-message').html('<div id="flash_error" class="error">Please upload thumbnail of image size 800 x 400</div>');
          error = true;
        }
      };
    }
    else { //No file was input or browser doesn't support client side reading
      if (!haveExistedImage800) {
        $("#thumbnail_800_error").html("Please upload thumbnail image").show();
        // $('.sys-message').html('<div id="flash_error" class="error">Please upload thumbnail of image size 800 x 400</div>');
        error = true;
      }
    }

    setTimeout(function() {
      if (error){
        console.log("Error in", error)
        return false;
      } else{
        console.log("else", error)
        $('body').addClass('busy');
        if ($('#upload_thumbnails').length > 0) {
          $('#upload_thumbnails').text('Saving...');
          $('#upload_thumbnails').attr('disable', true);
          $('#upload_thumbnails').css('pointer-events', 'none');
        }
        form.submit();
      }
    }, 1000)
  }

  $('#upload_thumbnails').on('click', function() {
    validate_thumbnails($('#frm_admin_movies_thumbnail'));
  });

});

  function setVideoDuration(e){
    movieId = document.getElementById("movie_video_src");
    if (movieId != null){
      movieId.preload = 'metadata';
      movieId.onloadedmetadata = function() {
        var duration = movieId.duration
        $('#video_file_duration').val(duration);
      }
    }
  }
