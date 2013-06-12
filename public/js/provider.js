
  var mobileDemo = { 'center': '57.7973333,12.0502107', 'zoom': 10 };
  var providerLocation = {};

  ////////////////////////////////////////////////////////////

  $(document).on('pageinit', '#directions', function() {
    demo.add('directions', function() {
      $("#map_canvas_1").gmap({'center': mobileDemo.center, 'zoom': mobileDemo.zoom, 'disableDefaultUI':true, 'callback': function() {
        var self = this;

        self.getCurrentPosition( function(position, status) {
          if ( status === 'OK' ) {
            console.log(position.coords);
            var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
            providerLocation = position.coords;
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
            providerLocation = position.coords;
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
