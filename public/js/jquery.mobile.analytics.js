var _gaq = _gaq || [];

$(document).ready(function(e) {
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
});

$(document).on('pageshow', '[data-role=page]', function(event, ui) {
  try {
    _gaq.push(['_setAccount', 'UA-42053724-1']);
    if ($.mobile.activePage.attr("data-url")) {
      _gaq.push(['_trackPageview', window.location.pathname + "#" + $.mobile.activePage.attr("data-url")]);
    } else {
      _gaq.push(['_trackPageview']);
    }
 } catch(err) {}
});
