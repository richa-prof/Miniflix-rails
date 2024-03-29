$(document).on('ready turbolinks:load', function(ev) {

  var targetPages = ['/provider/movies', '/provider/serials'];
  var basePath = window.location.pathname.split('/').slice(0,4).join('/');

  if (targetPages.indexOf(basePath) < 0 || $('body').data('mfx-video-listing')) {
    console.warn('skip video listing js code init for page ', window.location.pathname, ' on event ', ev.type);
    return;
  }

  $('body').data('mfx-video-listing', true);

  window.lockTimer = 0;

  if($('#tbl_provider_movies').length > 0) {
    summarizetable = $('#tbl_provider_movies').DataTable({
      "bPaginate": false,
      "searching": true,
      "bInfo" : false,
      "bSort" : false
    });
    $(".dataTables_filter").addClass("hide");
     $(".js-film-search").on('keyup', function (){
        $('#tbl_provider_movies').dataTable().fnFilter(this.value);
        $('#flash_success').text('Found '+ $('#tbl_provider_movies').find('tbody tr').length +' movies')
    });
  }

  //$('.js-film-search').focus();

  // $('.js-film-search').on('keyup', function(ev) {
  //   var el = $(ev.target);
  //   console.log(ev);

  //   if (el.val().length < 3 && !el.val().length) {
  //     return false;
  //   }
  //   window.lockTimer += 1
  //   setTimeout(function() {
  //     window.lockTimer -= 1;
  //     if (window.lockTimer > 0 ) {
  //       return false;
  //     }
  //     window.lockTimer = 0;
  //     var path = window.location.pathname;
  //     var params = $.deparam(window.location.search.replace('?',''));
  //     console.log('params', params);
  //     params['search'] = el.val();
  //     Turbolinks.visit(path + '?' + $.param(params));
  //   }, 400);

  // });

  $('.js-sort-dir').on('click', function(ev) {
    var el = $(ev.target);
    var sort_by = el.parent().data('sortby');
    console.log(el.parent().data('order'));
    var order = (el.parent().data('order') == 'asc') ? 'desc' : 'asc';
    window.lockTimer += 1;

    setTimeout(function() {
      window.lockTimer -= 1;
      if (window.lockTimer > 0 ) {
        return false;
      }
      if (order == 'asc') {
        el.addClass('fa-sort-up').removeClass('fa-sort-down');
      } else {
        el.addClass('fa-sort-down').removeClass('fa-sort-up');
      }
      window.lockTimer = 0;
      var path = window.location.pathname;
      var params = $.deparam(window.location.search.replace('?',''));
      params['sort_by'] = sort_by;
      params['order'] = order;
      console.log('params', params);
      Turbolinks.visit(path + '?' + $.param(params));
    }, 400);
  });

  console.warn('>> initialize code for movies/serials listing page');
});
