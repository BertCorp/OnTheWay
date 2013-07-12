// set up analytics account
ga_storage._setAccount('UA-42053724-1');
ga_storage._setDomain('none');
ga_storage._trackPageview('/index.html');

$(document).on('pageshow', '[data-role=page]', function(event, ui) {
  //console.log('google analytics pageshow')
  try {
    page = location.href.replace(/.*\//,'/')
    if (page && page.length > 1) {
      //console.log('google analytics pageshow url :'+page)
      ga_storage._trackPageview(page);
    } else {
      //console.log('google analytics pageshow default url')
      ga_storage._trackPageview();
    }
  } catch(err) {}
});
