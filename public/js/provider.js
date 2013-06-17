//////////////////////// Storage of local variables ///////////////////////////
var PROTOCOL = 'http://'; // DEVELOPMENT + PRODUCTION (for now)
var DOMAIN = 'localhost:3000'; // DEVELOPMENT
// var DOMAIN = 'www.onthewayhq.com'; // PRODUCTION
//var PROTOCAL = 'https://'; // PRODUCTION (YET TO BE IMPLEMENTED)
var API_PATH = '/api/v0';
var mobileDemo = { 'center': '57.7973333,12.0502107', 'zoom': 10 };
  var currentLocation = {},
          credentials = {},
         appointments = {};
      last_fetched_at = false;

///////////////////////////// Utility Functions ///////////////////////////////

  // Feature detect + local reference
  var storage = (function() {
        var uid = new Date,
            storage,
            result;
        try {
          (storage = window.localStorage).setItem(uid, uid);
          result = storage.getItem(uid) == uid;
          storage.removeItem(uid);
          return result && storage;
        } catch(e) {}
      }());

  function getStorage(name) {
    if (storage && (value = storage.getItem(name))) {
      return JSON.parse(value);
    }
    return false;
  }

  function setStorage(name, value) {
    if (storage) {
      return storage.setItem(name, JSON.stringify(value));
    }
    return false;
  }

  function removeStorage(name) {
    if (storage) {
      return storage.removeItem(name);
    }
    return false;
  }

  // Notification bar
  function setNotification(message) {
    $('#notification-bar p').html(message);
    $('#notification-bar').slideDown("fast");
  }

  function clearNotification() {
    $('#notification-bar').slideUp("slow", function() {
      $('#notification-bar p').html('');
      $(this).hide();
    });
  }

////////////////////////////// Page Functions /////////////////////////////////

  $(document).on('pagebeforeshow', '#login', function(){
    var data = {}
    //if (window.device && device.uuid) data.device_uid = device.uuid;
    // regardless, check for system updates
    $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/check.json',
      data: data,
      type: 'get',
      async: true,
      beforeSend: function() {
        // TODO: some type of indicator that we are checking for updates?
        setNotification('Checking server for updates...');
        setTimeout(clearNotification, 5000);
      },
      complete: function() {
        // TODO: remove indicator
        //clearNotification();
      },
      success: function(result) {
        // update based on results
        //console.log(result);
        if (result.protocol) {
          PROTOCOL = result.protocol;
        }
        /*if (result.provider) {
          credentials = result;
          setStorage('credentials', credentials);
          $.mobile.changePage("#home");
        }*/
        // TODO: Figure out how to handle other (unknown) updates without opening up security holes.
      },
      error: function(request) {
        // notify user about error checking for updates?
        //console.log(request);
        setNotification('There was an error retriving server updates.');
        setTimeout(clearNotification, 5000);
      }
    });

    if (credentials = getStorage('credentials')) {
      $.mobile.changePage("#home");
    }

    $(document).on('click', '#submit', function(e) { // catch the form's submit event
      e.preventDefault();
      if (($('#email').val().length > 0) && ($('#password').val().length > 0)) {
        // Send data to server through ajax call
        // action is functionality we want to call and outputJSON is our data
        $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/login.json',
          //data: { "provider" : { "email" : $('#email').val(), "password" : $('#password').val() } },
          data: $('form#login-form').serialize(),
          type: 'post',
          async: true,
          beforeSend: function() {
            // This callback function will trigger before data is sent
            $.mobile.showPageLoadingMsg(true); // This will show ajax spinner
          },
          complete: function() {
            // This callback function will trigger on data sent/received complete
            $.mobile.hidePageLoadingMsg(); // This will hide ajax spinner
          },
          success: function (result) {
            credentials = result;
            setStorage('credentials', credentials);
            $.mobile.changePage("#home");
          },
          error: function (request) {
            //console.log(request);
            //console.log(request.responseText);
            if (request.status == '401') {
              if (request.responseText.message) {
                alert(request.responseText.message);
              } else {
                alert('Invalid login attempt. Please make sure your credentials are accurate.');
              }
            } else {
              // This callback function will trigger on unsuccessful action
              alert('A network error has occurred. Please try again!');
            }
          }
        });
      } else {
        alert('Please fill in all fields.');
      }
      return false; // cancel original event to prevent form submitting
    });
  });

  $(document).on('pageinit', '#settings-options', function() {
    $('a#logout').click(function(e) {
      credentials = {};
      removeStorage('credentials');
      $.mobile.changePage("#login");
      return false;
    });
  });

  $(document).on('pageinit', '#directions', function() {
    demo.add('directions', function() {
      $("#map_canvas_1").gmap({'center': mobileDemo.center, 'zoom': mobileDemo.zoom, 'disableDefaultUI':true, 'callback': function() {
        var self = this;

        self.getCurrentPosition( function(position, status) {
          if ( status === 'OK' ) {
            console.log(position.coords);
            var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
            self.get('map').panTo(latlng);
            self.search({ 'location': latlng }, function(results, status) {
              if ( status === 'OK' ) {
                //$('#from').val(results[0].formatted_address);
                self.displayDirections({ 'origin': results[0].formatted_address, 'destination': $('#to').val(), 'travelMode': google.maps.DirectionsTravelMode.DRIVING }, { 'panel': document.getElementById('directions_list')}, function(response, status) {
                  ( status === 'OK' ) ? $('#results').show() : $('#results').hide();
                });
              }
            });
          } else {
            alert('Unable to get current position.');
          }
        });

        self.watchPosition(function(position, status) {
          if ( status === 'OK' ) {
            console.log(position.coords);
            var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            if ( !self.get('markers').client ) {
              self.addMarker({ 'id': 'client', 'position': latlng, 'bounds': true });
            } else {
              self.get('markers').client.setPosition(latlng);
              //map.panTo(latlng);
            }
          }
        });
      }});
    }).load('directions');
  });

  //$(document).on('pageshow', '#directions', function() {
  //  demo.add('directions', $('#map_canvas_1').gmap('get', 'getCurrentPosition')).load('directions');
  //});

  //$(document).on("pagehide", '#gps_map', function() {
  //  demo.add('directions', function() { $('#map_canvas_1').gmap('clearWatch'); }).load('directions');
  //});
