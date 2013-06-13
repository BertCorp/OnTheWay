/* Storage of local variables */
var mobileDemo = { 'center': '57.7973333,12.0502107', 'zoom': 10 };
//  var currentLocation = {},
//          credentials = {},
//         appointments = {};

////////////////////////////////////////////////////////////

  $(document).on('pagebeforeshow', '#login', function(){
    $(document).on('click', '#submit', function(e) { // catch the form's submit event
      e.preventDefault();
      if (($('#username').val().length > 0) && ($('#password').val().length > 0)) {
        // Send data to server through ajax call
        // action is functionality we want to call and outputJSON is our data
        $.ajax({url: 'check.php',
            data: {action : 'login', formData : $('#check-user').serialize()}, // Convert a form to a JSON string representation
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
              resultObject.formSubmitionResult = result;
              $.mobile.changePage("#home");
            },
            error: function (request,error) {
                // This callback function will trigger on unsuccessful action
                alert('Network error has occurred please try again!');
            }
        });
      } else {
        alert('Please fill all nececery fields');
      }
      return false; // cancel original event to prevent form submitting
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
