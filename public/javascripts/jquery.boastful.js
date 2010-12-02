(function ($) {
  $.fn.boastful = function(options){
    options = options || {}
    var output = $(this)
    var defaults = {
                      location: location.href,
                      empty_message: 'No one\'s mentioned this page on Twitter yet. '+
                                       '<a href="http://twitter.com?status='+(options.empty_message || location.href)+'">'
                                       +'You could be the first</a>.',
                      limit: 50
                   }
    var settings = $.extend(defaults, options)

    function format_tweetback(tweetback) {
      formatted  = ''
      formatted += '<div class="boastful">'
      formatted +=   '<a href="'+tweetback.permalink_url+'">'
      formatted +=     '<img src="'+tweetback.author.photo_url+'" />'
      formatted +=   '</a>'
      formatted +=   '<div class="boastful_pointer"></div>'
      formatted +=   '<div class="boastful_tweet" style="display: none">'
      formatted +=     '<div class="boastful_handle">@'+tweetback.author.url.split('/').pop()+'</div>'
      formatted +=     '<div class="boastful_content">'+tweetback.content+'</div>'
      formatted +=   '</div>'
      formatted += '</div>'
      return formatted
    }

    var parse_request = function(data){
      var author_urls = [];
      if(data.response.list.length > 0) {
        $.each(data.response.list, function(i,tweetback){
          if($.inArray(tweetback.author.url,author_urls) > -1) {
            return true
          }
          author_urls.push(tweetback.author.url)
          output.append(format_tweetback(tweetback))
          $('.boastful').mouseover(function(){ $(this).children('.boastful_tweet, .boastful_pointer').show() })
          $('.boastful').mousemove(function(kmouse){
            $(this).children('.boastful_tweet').css({
              left:$(this).position().left-105,
              top:$(this).position().top+25
            })
            $(this).children('.boastful_pointer').css({
              left:$(this).position().left+18,
              top:$(this).position().top+15
            })
          })
          $('.boastful').mouseout(function(){ $(this).children('.boastful_tweet, .boastful_pointer').hide() })
        });
      } else {
        output.append(defaults.empty_message)
      }
    }

    $.ajax({
      url:'http://otter.topsy.com/trackbacks.js',
      data:
        {
          url: defaults.location,
          perpage: defaults.limit
        },
      success:parse_request,
      dataType:'jsonp'}
    );

    return this
  }
})(jQuery);
