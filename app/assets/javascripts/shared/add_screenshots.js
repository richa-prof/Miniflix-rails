$(document).on('ready turbolinks:load', function(ev) {

  // alt. way - analize body[data-page]
  var targetPages = [
   '/provider/serials/add_screenshots', '/provider/movies/add_screenshots', '/provider/serials/add_thumbnails', '/provider/movies/add_thumbnails', 
   '/admin/movies/add_movie_details', '/admin/movies/edit', '/admin/serials/edit'
  ];

  var basePath1 = window.location.pathname.split('/').slice(0,4).join('/');
  var bp2 = window.location.pathname.split('/');
  bp2.splice(3,1);
  basePath2 = bp2.join('/');
  // console.log(basePath1, basePath2);

  if (targetPages.indexOf(basePath1) < 0 && targetPages.indexOf(basePath2) < 0) {
    console.warn('skip add_screenshot js code init for page', window.location.pathname);
    return;
  }

  // avoid double init
  if ($('body').attr('data-mfx-add-screenshots') == self.bid) {
    console.warn('skipping initializing code related to adding screenshots/thumbnails on event ', ev.type);
    return false;
  }
  $('body').attr('data-mfx-add-screenshots', self.bid); 

  console.warn('initialize code related to adding screenshots/thumbnails on event ', ev.type);
  
  window.URL = window.URL || window.webkitURL;

  window.validate_thumbnails = function(form){
    var fileInput = $("#thumbnail_screenshot");
    var file = fileInput[0].files && fileInput[0].files[0];

    var fileInput640 = $("#thumbnail_640_screenshot");
    file640 = fileInput640[0].files && fileInput640[0].files[0];

    var fileInput800 = $("#thumbnail_800_screenshot");
    file800 = fileInput800[0].files && fileInput800[0].files[0];

    var error = false;
    if( file ) {
      var img = new Image();
      img.src = window.URL.createObjectURL( file );

      img.onload = function() {
        var width = img.naturalWidth,
          height = img.naturalHeight;

        window.URL.revokeObjectURL( img.src );

        if( width == 330 && height == 360 ) {
          // form.submit();
        }
        else {
            //fail
          $("#thumbnail_error").html("Please upload image with 330x360 size only").show();
          error = true;
        }
      };
    }
    else { //No file was input or browser doesn't support client side reading
      // unless @provider_movie.movie_thumbnail.thumbnail_screenshot.present? %>
        $("#thumbnail_error").html("Please upload thumbnail image").show();
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
        }
        else {
            //fail
          console.log("invalid dimention==>",width,"--height-->",height)
          $("#thumbnail_640_error").html("Please upload image with 600x300 size only").show();
          error = true;
        }
      };
    }
    else { //No file was input or browser doesn't support client side reading
      // unless @provider_movie.movie_thumbnail.thumbnail_640_screenshot.present? %>
        $("#thumbnail_640_error").html("Please upload thumbnail image").show();
        error = true;
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
        }
        else {
            //fail
          console.log("invalid dimention==>",width,"--height-->",height)
          $("#thumbnail_800_error").html("Please upload image with 800x400 size only").show();
          error = true;
        }
      };
    }
    else { //No file was input or browser doesn't support client side reading
      // unless @provider_movie.movie_thumbnail.thumbnail_640_screenshot.present? %>
        $("#thumbnail_800_error").html("Please upload thumbnail image").show();
        error = true;
    }

    setTimeout(function() {
      if (error){
        console.log("Error in", error)
        return false;
      } else{
        console.log("else", error)
        form.submit();
      }
    }, 1000)
  }

});


