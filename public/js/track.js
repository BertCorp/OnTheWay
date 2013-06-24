
$.track = {
  // variables to store
  appointment_id  : false,
  origin          : {},
  current         : {},
  destination     : {},
  threshold       : 200,
  ttl             : (1000*60*15),

  // check to see if we can use geolocation
  check : function() {
    if (!navigator.geolocation) {
      log("Can't use geolocation. Stopping.");
      alert("Unable to track your position. This is either because your device doesn't allow it or you didn't give us permission.");
      return false;
    }
    return true;
  }, // check
  // Container for all the actual watching code needed.
  watch : {
    id : false,
    start : function() {
      $.track.watch.stop();
      $.track.watch.id = navigator.geolocation.watchPosition($.track.watch.success, $.track.watch.failure, $.track.watch.options);
      log("Start Watching: " + $.track.watch.id);
      return $.track.watch.id;
    }, // start
    stop : function() {
      if ($.track.watch.id) {
        var watch_id = $.track.watch.id;
        $.track.watch.id = false;
        log("Stop Watching: " + watch_id);
        return navigator.geolocation.clearWatch(watch_id);
      }
    }, // stop
    success : function(position) {
      if (position.coords.accuracy <= $.track.threshold) {
        // should this be tracked only on start?
        /*if (!$.track.start.timestamp) {
          $.track.start = position.coords;
          $.track.start.timestamp = position.timestamp;
        }*/
        $.track.current = position.coords;
        $.track.current.timestamp = position.timestamp;
        // update map if we are viewing it.
        updateProviderOnMap(position.coords);
        $.track.updateServer();
      }
    }, // success
    failure : function(error) {
      log('track.watch.failure -- ' + $.track.watch.id + ' // code: ' + error.code + ' -- ' + 'message: ' + error.message);
      // if it's a timeout, we're good. anything else, we don't know how to handle yet.
      if (error.code != 3) alert('code: ' + error.code + '\n' + 'message: ' + error.message + '\n');
      $.track.watch.start();
    }, // failure
    options : {
      enableHighAccuracy: true,
      timeout: 20000,
      maximumAge: 0
    } // options
  }, // watch
  // Update the OnTheWay servers with this tracking data, so we can let the customer know.
  updateServer : function() {
    // don't proceed if we have a bad appointment_id. something broke.
    //if (!$.track.appointment_id) return $.track.stop();
    var appointment_id = ($.track.appointment_id) ? $.track.appointment_id : current_appointment_id;
    var tracking = { 'current' : $.track.current, 'timestamp' : $.now() };
    if ($.track.appointment_id) tracking.appointment_id = $.track.appointment_id;
    if ($.track.origin) tracking.origin = $.track.origin;

    // update server with latest tracking info.
    $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments/' + appointment_id + '/tracking.json',
      data: { 'auth_token' : credentials.auth_token, 'tracking' : tracking },
      type: 'put',
      async: true,
      beforeSend: function() {},
      complete: function() {},
      success: function(result) {
        // upon success,
        // update appointment ETA?
      },
      error: function(request) {
        setNotification('There was an error updating your location...');
        setTimeout(clearNotification, 3000);
      }
    });
  }, // updateServer
  // begin the tracking process for this appointment.
  start : function(appointment_id) {
    log('begin tracking appointment #' + appointment_id);
    if (!$.track.check()) return false;
    $.track.watch.stop();
    // begin informing the provider that we are tracking their location...
    $('#tracking-bar p').html("Currently tracking your location...");
    $('#tracking-bar').slideDown(200);
    $('.ui-mobile [data-role=page], .ui-mobile [data-role=dialog], .ui-page').animate({ top: '18px' }, 200);
    $.track.appointment_id = appointment_id;
    // get provider's current (start) location and when done, start watching user's location.
    $.track.startLocation();
  }, // start
  // get a provider's current (start) location before starting to watch/track their location.
  startLocation : function() {
    log("Get user's current (start) location!");
    // if we already have a current location that isn't too old, just use that
    if ($.track.current.timestamp && (($.track.current.timestamp + $.track.ttl) > $.now())) {
      $.track.origin = $.track.current;
      $.track.updateServer();
      return $.track.watch.start();
    }

    navigator.geolocation.getCurrentPosition(function(position) {
      if (position.coords.accuracy <= $.track.threshold) {
        $.track.origin = position.coords;
        $.track.origin.timestamp = position.timestamp;
        $.track.current = position.coords;
        $.track.current.timestamp = position.timestamp;
        log("Got new current (start) location: " + JSON.stringify(position.coords));
        // upload tracker to server
        $.track.updateServer();
        $.track.watch.start();
      } else {
        // if we are beyond the threshold, let's try again.
        log("getStartLocation:success // above threshold: " + position.coords.accuracy);
        $.track.startLocation();
      }
    }, function(error) {
      log('getStartLocation:failure // code: ' + error.code + ' -- ' + 'message: ' + error.message);
      // if it's a timeout, we're good. anything else, we don't know how to handle yet.
      if (error.code != 3) alert('code: ' + error.code + '\n' + 'message: ' + error.message + '\n');
      $.track.startLocation(); // try again
    }, {
      enableHighAccuracy: true,
      timeout: 30000,
      maximumAge: 0
    });
  }, // startLocation
  // if tracking has ceased, resume it.
  resume : function() {
    log('resume tracking appointment #' + $.track.appointment_id);
    if (!$.track.check()) return false;
    $('.ui-mobile [data-role=page], .ui-mobile [data-role=dialog], .ui-page').css({ top: '18px' });
    $('#tracking-bar p').html("Currently tracking your location...");
    $('#tracking-bar').show();
    if (!$.track.watch.id) {
      $.track.watch.start();
    } else {
      log('Already tracking appointment #' + $.track.appointment_id + ' with watch.id #' + $.track.watch.id);
    }
  }, // resume
  // end the tracking process.
  stop : function() {
    log("STOP ALL TRACKING!");
    // clear variables.
    $.track.watch.stop();
    $.track.origin = {};
    $.track.current = {};
    // clear notifications for user.
    $('.ui-mobile [data-role=page], .ui-mobile [data-role=dialog], .ui-page').animate({ top: '0px' }, 600);
    $('#tracking-bar').slideUp(600, function() {
      $('#tracking-bar p').html('');
      $(this).hide();
    });
    // let server know provider has stopped tracking.
    if ($.track.appointment_id) {
      $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments/' + $.track.appointment_id + '/tracking.json',
        data: { 'auth_token' : credentials.auth_token },
        type: 'delete',
        async: true,
        success: function(result) {
          log("Server alerted to stop tracking.");
        }
      });
      $.track.appointment_id = false;
    }
  } // stop
} // $.track
