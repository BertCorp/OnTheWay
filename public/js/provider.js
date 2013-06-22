//////////////////////// Storage of local variables ///////////////////////////
        var DEVELOPMENT = true,
               PROTOCOL = 'http://', // DEVELOPMENT
                 DOMAIN = 'localhost:3000', // DEVELOPMENT
               //DOMAIN = 'www.onthewayhq.com', // PRODUCTION
             //PROTOCAL = 'https://', // PRODUCTION (YET TO BE IMPLEMENTED)
               API_PATH = '/api/v0',
             mobileDemo = { 'center': '57.7973333,12.0502107', 'zoom': 10 },
               tracking = {
                            'tracker_id'      : false,
                            'start'           : {},
                            'current'         : {},
                            'timestamp'       : false,
                            'appointment_id'  : false
                          },
            credentials = {},
           appointments = false,
       appointments_key = {},
 current_appointment_id = false,
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
    if (DEVELOPMENT) console.log(message);
    $('#notification-bar p').html(message);
    $('#notification-bar').slideDown(200);
  }

  function clearNotification() {
    setTimeout(function() {
      $('#notification-bar').slideUp(600, function() {
        $('#notification-bar p').html('');
        $(this).hide();
      });
    }, 2000);
  }

  function startTracking(appointment_id) {
    if (!navigator.geolocation) {
      alert("Unable to properly track your position.");
      return false;
    }
    console.log('startTracking -- ' + appointment_id);
    $('#tracking-bar p').html("Currently tracking your location...");
    $('#tracking-bar').slideDown(200);
    $('.ui-mobile [data-role=page], .ui-mobile [data-role=dialog], .ui-page').animate({ top: '18px' }, 200);
    tracking['appointment_id'] = appointment_id;
    // get current position
    navigator.geolocation.getCurrentPosition(function(position) {
      //coords: { accuracy: 37, latitude: 41.9072343, longitude: -87.67032619999999 }, timestamp: 1371849376725
      tracking['start'] = position.coords;
      tracking['current'] = position.coords;
      tracking['timestamp'] = position.timestamp;
      updateTracking();
      track();
    });
  } // startTracking

  function track() {
    if (!tracking['timestamp']) tracking = getStorage('tracking');
    if (DEVELOPMENT) console.log('updateTracking');
    if (DEVELOPMENT) console.log(tracking);

    $('#tracking-bar p').html("Currently tracking your location...");
    $('#tracking-bar').show();
    $('.ui-mobile [data-role=page], .ui-mobile [data-role=dialog], .ui-page').css({ top: '18px' });

    tracking['tracker_id'] = navigator.geolocation.watchPosition(function(position) {
      if (DEVELOPMENT) console.log("updateTracking -- watchPosition");
      tracking['current'] = position.coords;
      tracking['timestamp'] = position.timestamp;
      setStorage('tracking', tracking); // store locally
      if (DEVELOPMENT) console.log(tracking);
      // upload tracker to server
      updateTracking();
    }, function() {
      //console.log('watchPosition -- error!');
    }, {
      enableHighAccuracy: true,
      //timeout: 60000,
      maximumAge: 0
    });
    setStorage('tracking', tracking); // store locally
  } // track

  function updateTracking() {
    $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments/' + tracking['appointment_id'] + '/tracking.json',
      data: { 'auth_token' : credentials.auth_token, 'tracking' : tracking },
      type: 'put',
      async: true,
      beforeSend: function() {},
      complete: function() {},
      success: function(result) {
        // upon success,
        //if (DEVELOPMENT) console.log(result);
        // update appointment ETA?
      },
      error: function(request) {
        setNotification('There was an error updating your location...');
        setTimeout(clearNotification, 3000);
      }
    });
  } // updateTracking

  function stopTracking() {
    // stop watching provider's position
    if (navigator.geolocation && tracking && tracking['tracker_id'])
      navigator.geolocation.clearWatch(tracking['tracker_id']);
    // reset tracker variable.
    tracking['tracker_id'] = false;
    tracking['start'] = {};
    tracking['current'] = {};
    tracking['timestamp'] = false;
    tracking['appointment_id'] = false;

    $('.ui-mobile [data-role=page], .ui-mobile [data-role=dialog], .ui-page').animate({ top: '0px' }, 600);
    $('#tracking-bar').slideUp(600, function() {
      $('#tracking-bar p').html('');
      $(this).hide();
    });
  } // stopTracking

////////////////////////// Appointment Functions //////////////////////////////

  function getAppointmentLabelClass(status) {
    switch (status) {
      case "finished" :
        return "label-success";
        break;
      case "en route" :
      case "arrived" :
      case "in progress" :
        return "label-warning";
        break;
      case "confirmed" :
        return "label-info";
        break;
      case "canceled" :
      case "missed" :
      case "late" :
        return "label-important";
        break;
      default:
        return "";
    }
  } // getAppointmentLabelClass

  function formatAppointmentStatus(status) {
    switch (status) {
      case "arrived" :
        return "IN PROGRESS";
        break;
      case "en route" :
      case "missed" :
      case "late" :
        return status.toUpperCase();
    }
    return status;
  } // formatAppointmentStatus

  function handleErrors(request, preferred_message) {
    $('#notification-bar p').html('');
    $('#notification-bar').hide();
    var responseText = JSON.parse(request.responseText);
    if (request.status == '401') {
      if (responseText.message) {
        alert(responseText.message);
      } else {
        alert('Invalid login attempt. Please make sure your credentials are accurate.');
      }
    } else if (request.status == '422') {
      if (preferred_message) {
        alert(preferred_message);
      } else if (responseText.message) {
        alert(responseText.message);
      } else {
        alert('An error has occurred. Please check to make sure you supplied the necessary information.');
      }
    } else {
      // This callback function will trigger on unsuccessful action
      alert('A network error has occurred. Please try again!');
    }
  } // handleErrors

  function renderAppointment(appointment_id) {
    current_appointment_id = appointment_id;
    appointment = appointments[appointments_key[appointment_id]];
    if (DEVELOPMENT) console.log(appointment);
    // update Details page with appointment/customer data.
    $('#detail h1').html(appointment.customer.name);
    $('#detail #customer-name').html(appointment.customer.name);
    $('#detail #customer-email').html('<a href="mailto:' + appointment.customer.email + '">' + appointment.customer.email + '</a>');
    $('#detail #customer-phone').html(appointment.customer.phone);
    $('#detail #customer-text').attr('href', 'sms:+1' + appointment.customer.phone.replace(/\D/g,''));
    $('#detail #customer-call').attr('href', 'tel:+1' + appointment.customer.phone.replace(/\D/g,''));
    $('#detail #appointment-when').html(appointment.starts_at.slice(0, -6));

    $('#progress-btn-container').show();
    if (appointment.status == 'requested') {
      $('#progress-btn-container a').attr('data-status', 'confirmed').find('span span').html('Mark as Confirmed');
    } else if ((!appointment.en_route_at) && ((new Date(appointment.starts_at).getTime() - $.now()) < 1000*60*60*4)) {
      $('#progress-btn-container a').attr('data-status', 'en route').find('span span').html('On My Way');
    } else if ($.inArray(appointment.status, ['en route', 'late']) >= 0) {
      $('#progress-btn-container a').attr('data-status', 'arrived').find('span span').html("I've Arrived");
    } else if (appointment.status == 'arrived') {
      $('#progress-btn-container a').attr('data-status', 'finished').find('span span').html("I'm Finished");
    } else {
      $('#progress-btn-container').hide();
      $('#progress-btn-container a').attr('data-status', '').find('span span').html("");
    }

    if ($.inArray(appointment.status, ['canceled', 'missed', 'finished']) >= 0) {
      // should there be some other indicator/options on the page?
      $('#cancel-btn-container').hide();
    } else {
      $('#cancel-btn-container').show();
    }

    $('#detail #appointment-status')
      .removeClass().addClass('label').addClass(getAppointmentLabelClass(appointment.status))
      .attr('title', appointment[appointment.status + "_at"])
      .html(formatAppointmentStatus(appointment.status));
    // should put info underneath, depending on what the status is...
    var status_time = 'Created: ' + appointment.created_at.slice(0, -6)  + '<br/>';
    if (appointment.confirmed_at) status_time += 'Confirmed: ' + appointment.confirmed_at.slice(0, -6)  + '<br/>';
    if (appointment.en_route_at)  status_time += 'En Route: ' + appointment.en_route_at.slice(0, -6)  + '<br/>';
    if (appointment.arrived_at)   status_time += 'Arrived: ' + appointment.arrived_at.slice(0, -6)  + '<br/>';
    if (appointment.finished_at)  status_time += 'Finished: ' + appointment.finished_at.slice(0, -6)  + '<br/>';
    if (appointment.status == 'canceled') status_time += 'Canceled: ' + appointment.updated_at.slice(0, -6) + '<br/>';
    $('#detail #appointment-status-times').html(status_time);

    $('#detail #appointment-location').html(appointment.location);
    $('#detail #appointment-notes').html(appointment.notes.replace(/\n/g, '<br />'));
    $('#detail #appointment-shorturl').html('<a href="' + appointment.shorturl + '">' + appointment.shorturl + '</a>');
    // update Directions page
    $('#directions #to').val(appointment.location.replace(/\r\n/g, ' '));
    // update edit appointment page
    $('#edit_appointment_starts_at').val(appointment.starts_at.substr(0, 10));
    $('#edit_appointment_starts_at_time').val(appointment.starts_at.substr(11, 5));
    $('#edit_appointment_location').val(appointment.location);
    $('#edit_appointment_status').val(appointment.status);
    $('#edit_appointment_notes').html(appointment.notes);

  } // renderAppointment

  function renderAppointments() {
    if (!appointments) appointments = getStorage('appointments');
    if (!appointments || (appointments.length <= 0)) {
      $('ul#appointments-container').html($('#empty-tmpl').html());
    } else {
      // if appointments exist, load them in.
      $('ul#appointments-container').html('');
      var date = $('#date-tmpl').html();
      var appointment = $('#appointment-tmpl').html();
      var current_date = false;
      var current_count = 0;
      var is_tracking = false;
      for (x in appointments) {
        if (!current_date || (current_date != appointments[x].starts_at.substr(0,10))) {
          // update last date divider's appointment count
          if (current_date) $('#date-' + current_date + ' span.ui-li-count').html(current_count);
          // now let's set our new current date and create the new date divider
          // $.datepicker.formatDate('yy/mm/dd', appointments[x].starts_at);
          current_date = appointments[x].starts_at.substr(0,10);
          current_count = 0;
          var date_item = date.replace(/{{date}}/g, current_date);
          $('ul#appointments-container').append(date_item);
        }
        current_count++;
        //console.log(appointments[x]);
        // fix some status stuff.
        if ($.inArray(appointments[x].status, ["finished", "canceled", "arrived", "en route"]) < 0) {
          // if we are past the start time of an appointment we should be at or already finished
          if ($.now() - new Date(appointments[x].starts_at).getTime() > 1000*60*5) {
            // and it's past the start time + 2 hours, it's MISSED, otherwise, it's LATE.
            appointments[x].status = (($.now() - new Date(appointments[x].starts_at).getTime()) > 1000*60*60*2) ? "missed" : "late";
          }
        }

        var time = appointments[x].starts_at.substr(11, 5);
        if (time == '00:00') time = "";
        var appointment_item = appointment.replace(/{{id}}/g, appointments[x].id);
        appointment_item = appointment_item.replace(/{{name}}/g, appointments[x].customer.name);
        appointment_item = appointment_item.replace(/{{hidden}}/g, appointments[x].customer.email + " -- " + appointments[x].customer.phone);
        appointment_item = appointment_item.replace(/{{time}}/g, time);
        appointment_item = appointment_item.replace(/{{status}}/g, formatAppointmentStatus(appointments[x].status));
        appointment_item = appointment_item.replace(/{{label-class}}/g, getAppointmentLabelClass(appointments[x].status));
        $('ul#appointments-container').append(appointment_item);
        // start tracking if we need to for any app.
        if (appointments[x].status == 'en route') {
          is_tracking = true;
          if (!tracking['timestamp']) {
            tracking['appointment_id'] = appointments[x].id;
            track(appointments[x].id);
          }
        }
      }
      $('#date-' + current_date + ' span.ui-li-count').html(current_count);
      if (!is_tracking) stopTracking();
    }
    $('ul#appointments-container').listview('refresh');
  } // renderAppointments

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
        setNotification('Checking server for updates...');
      },
      complete: function() {
        clearNotification();
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
        setNotification('There was an error retrieving server updates.');
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
            handleErrors(request);
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

  $(document).on('pagebeforeshow', '#home', function() {
    current_appointment_id = false; // reset current appointment
    renderAppointments(); // render all the appointments
    // only check for updates every 5 minutes
    if (last_fetched_at && (($.now() - last_fetched_at) < 1000*60*5)) return true;
    // then check with server to see if we have updated list and load in new list.
    $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments.json',
      data: { 'auth_token' : credentials.auth_token },
      type: 'get',
      async: true,
      beforeSend: function() {
        setNotification('Checking server for new appointments...');
      },
      complete: function() {
        clearNotification();
      },
      success: function(result) {
        last_fetched_at = $.now();
        appointments = result;
        setStorage('appointments', appointments);
        for (x in appointments) {
          appointments_key[appointments[x].id] = x;
        }
        renderAppointments();
      },
      error: function(request) {
        // notify user about error checking for updates?
        //console.log(request);
        setNotification('There was an error retrieving updated appointments.');
        setTimeout(clearNotification, 5000);
      }
    });
  });

  $(document).on('click', '.appointments a', function(e) {
    var appointment_id = $(this).parents('.appointments').attr('id').substr('appointment-'.length);
    renderAppointment(appointment_id);
  });

  $(document).on('click', '#progress-btn-container a', function() {
    var status = $(this).attr('data-status');
    $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments/' + current_appointment_id + '.json',
      data: { 'auth_token' : credentials.auth_token, 'appointment' : { 'status' : status } },
      type: 'put',
      async: true,
      beforeSend: function() {
        setNotification('Updating appointment status...');
      },
      complete: function() {
        clearNotification();
      },
      success: function(result) {
        // upon success,
        if (DEVELOPMENT) console.log(result);
        appointments[appointments_key[current_appointment_id]] = result;
        if (result.status == 'en route') startTracking(current_appointment_id);
        if (result.status == 'finished') stopTracking();
        setStorage('appointments', appointments);
        renderAppointment(current_appointment_id);
        // update appointments? do results return updated appointments? or just returning #home refresh?
        $('#dialog-success h3').html("Appointment status has been updated.");
        $.mobile.changePage("#dialog-success", {transition: 'pop', role: 'dialog'});
      },
      error: function(request) {
        handleErrors(request, 'There was an error updating this appointment\'s status.');
      }
    });
  });

  $(document).on('pagebeforeshow', '#directions', function() {
    var self, map_initial = {};
    demo.add('directions', function() {
      $("#map_canvas_1").gmap({'center': mobileDemo.center, 'zoom': mobileDemo.zoom, 'disableDefaultUI':true, 'callback': function() {
        self = this;

        self.getCurrentPosition( function(position, status) {
          if ( status === 'OK' ) {
            //console.log(position.coords);
            var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
            self.get('map').panTo(latlng);
            self.search({ 'location': latlng }, function(results, status) {
              if ( status === 'OK' ) {
                //$('#from').val(results[0].formatted_address);
                self.displayDirections({ 'origin': results[0].formatted_address, 'destination': $('#to').val(), 'travelMode': google.maps.DirectionsTravelMode.DRIVING }, { 'panel': document.getElementById('directions_list')}, function(response, status) {
                  ( status === 'OK' ) ? $('#results').show() : $('#results').hide();
                  setTimeout(function() {
                    if (DEVELOPMENT) console.log('ETA: ' + $('#directions_list .adp-summary').text());
                    map_initial['center'] = self.get('map').getCenter();
                    map_initial['zoom'] = self.get('map').getZoom();
                  }, 100);
                });
              }
            });
          } else {
            alert('Unable to get current position.');
          }
        });

        self.watchPosition(function(position, status) {
          if ( status === 'OK' ) {
            //console.log(position.coords);
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

    $(document).on('click', 'a#directions-recenter', function(e) {
      e.preventDefault();
      self.get('map').setCenter(map_initial['center']);
      self.get('map').setZoom(map_initial['zoom']);
    });
  });

  $(document).on('pageinit', '#dialog-cancel-confirm', function() {
    $(document).on('click', '#cancel-appointment', function() {
      $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments/' + current_appointment_id + '.json',
        data: { 'auth_token' : credentials.auth_token, 'appointment' : { 'status' : 'canceled' } },
        type: 'put',
        async: true,
        beforeSend: function() {
          setNotification('Canceling appointment...');
        },
        complete: function() {
          clearNotification();
        },
        success: function(result) {
          // upon success,
          appointments[appointments_key[current_appointment_id]] = result;
          setStorage('appointments', appointments);
          renderAppointments();
          // go back to #home
          $.mobile.changePage("#home");
        },
        error: function(request) {
          // notify user about error checking for updates?
          //console.log(request);
          handleErrors(request, 'There was an error canceling this appointment. Please try again or use the web console.');
        }
      });
    });
  });

  $(document).on('pageinit', '#appointment-add', function() {
    current_appointment_id = false;
    var today = new Date();
    var m = today.getMonth() + 1;
    $('#appointment_starts_at').val(today.getFullYear() + '-' + (m < 10 ? '0' : '') + m + '-' + today.getDate());

    $(document).on('click', '#appointment-add .appointment-submit', function(e) {
      // do validation on the data
      e.preventDefault();
      if (($('#appointment_customer_name').val().length > 0) && ($('#appointment_customer_phone').val().length > 0) && ($('#appointment_starts_at').val().length > 0) && ($('#appointment_location').val().length > 0)) {
        var data = $('#appointment-add form').serialize();
        data['auth_token'] = credentials.auth_token;
        $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments.json',
          data: data,
          type: 'post',
          async: true,
          beforeSend: function() {
            setNotification('Saving new appointment...');
          },
          complete: function() {
            clearNotification();
          },
          success: function(result) {
            // upon success,
            last_fetched_at = false;
            // go back to #home, which should update and show new appointment
            $.mobile.changePage("#home");
          },
          error: function(request) {
            handleErrors(request);
          }
        });
      } else {
        alert('Please fill in all necessary fields.');
      }
    });

  });

  $(document).on('pageinit', '#appointment-edit', function() {
    $(document).on('click', '#appointment-edit .appointment-submit', function(e) {
      // do validation on the data
      e.preventDefault();
      if (($('#edit_appointment_starts_at').val().length > 0) && ($('#edit_appointment_location').val().length > 0)) {
        var data = $('#appointment-edit form').serialize();
        data['auth_token'] = credentials.auth_token;
        $.ajax({ url: PROTOCOL + DOMAIN + API_PATH + '/appointments/' + current_appointment_id + '.json',
          data: data,
          type: 'put',
          async: true,
          beforeSend: function() {
            setNotification('Saving appointment...');
          },
          complete: function() {
            clearNotification();
          },
          success: function(result) {
            // upon success,
            last_fetched_at = false;
            appointments[appointments_key[current_appointment_id]] = result;
            setStorage('appointments', appointments);
            // go back to #home, which should update and show new appointment
            $.mobile.changePage("#home");
          },
          error: function(request) {
            handleErrors(request);
          }
        });
      } else {
        alert('Please fill in all necessary fields.');
      }
    });

  });

  //$(document).on("pagehide", '#gps_map', function() {
  //  demo.add('directions', function() { $('#map_canvas_1').gmap('clearWatch'); }).load('directions');
  //});
