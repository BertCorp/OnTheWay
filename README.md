OnTheWay
========

- Customer Web Panel: http://www.onthewayhq.com
- Provider Mobile App: http://www.onthewayhq.com/mobile/
- Customer Appointment: http://www.onthewayhq.com/customer/
- Customer Feedback: http://www.onthewayhq.com/feedback/


Todos
=====
- mobile prototype for providers
  - ~~update and build out api endpoint structure~~ 2013-06-16
  - ~~figure out api response structure~~ 2013-06-16
  - ~~functional provider login/authentication~~ 2013-06-16
  - ~~get api access w/ auth token working~~ 2013-06-16
  - ~~do initial server check upon app launch and before any data is requested/sent~~ 2013-06-17
    - ~~some type of indicator that system check is happening~~ 2013-06-17
  - ~~storing valid user (local storage)~~ 2013-06-17
  - ~~appointment blank slate~~ 2013-06-17
  - ~~display provider customers/appointments~~ 2013-06-17
  - ~~recenter directions map~~ 2013-06-18
  - ~~individual appointment sub views~~ 2013-06-18
    - ~~cancel~~ 2013-06-18
    - ~~display status date/times~~ 2013-06-20
  - ~~appointment status updates~~ 2013-06-18
    - ~~Cancel~~ 2013-06-18
    - ~~On My Way (en route)~~ 2013-06-18
    - ~~I've Arrived~~ 2013-06-18
    - ~~I'm Finished~~ 2013-06-18
  - ~~functional shortcode urls~~ 2013-06-19
  - ~~allow providers to add appointment~~ 2013-06-20
  - ~~change appointment info~~ 2013-06-20
  - ~~provider location tracking~~ 2013-06-21
  - ~~fix directions to work with tracking.~~ 2013-06-22
  - ~~clear add appointment fields on save.~~ 2013-06-22
  - ~~stop tracking on logout.~~ 2013-06-22
  - ~~double alert empty field after logout.~~ 2013-06-22
  - ~~view provider position on current appointment map.~~ 2013-06-22
  - ~~clean up logging situation.~~ 2013-06-23
  - ~~add spinner/loader while trying to find location~~ 2013-06-23
  - ~~fix tracking~~ 2013-06-24
    - ~~restructure~~ 2013-06-23
    - ~~be more efficient~~ 2013-06-23
    - ~~store current location when fetched.~~ 2013-06-24
- mobile prototype for customers
  - ~~dynamic~~ 2013-06-19
  - ~~cancel appointment~~ 2013-06-19
  - ~~customer feedback~~ 2013-06-19
    - ~~figure out auth token situation for api access~~ 2013-06-19
  - ~~provider tracking~~ 2013-06-25
  - ~~add eta/last of on map/directions page.~~ 2013-06-25
  - auto update queue/eta
- appointment ETA -- https://developers.google.com/maps/documentation/javascript/reference#DirectionsService
- twilio integration
  - ~~account setup and funded~~ 2013-06-22
- native apps via phonegap -- http://docs.phonegap.com/en/2.8.0/cordova_device_device.md.html#Device
- walkthrough apps/process
- simplify app/process


Down the Road
=============
- Providers
  - appointment types
  - metadata fields (ability for companies/providers to add custom fields to appointments)
  - better offline handling
  - listview pull to refresh -- https://github.com/watusi/jquery-mobile-iscrollview
  - if provider hasn't marked job as finished, send him a friendly reminder to.
  - edit appointment customer info
- activity log
- full CRM functionality
- auto "next"
- function buttons on directions page.
- timezone fix -- http://stackoverflow.com/questions/4362663/timezone-with-rails-3

=========
- ~~(web) update input fields to html5 field types~~ 2013-06-07
- ~~(web) proper saving of when date and time~~ 2013-06-07
- ~~(mobile) finish functional html mockups~~
  - ~~finish appointment list view~~ 2013-06-07
  - ~~appointment detail view~~ 2013-06-07
  - ~~map / directions~~ 2013-06-08
- ~~customer appointment functional html mockups~~
  - ~~basic appointment page~~ 2013-06-09
  - ~~feedback/share page~~ 2013-06-10
- ~~[bug] fix api appointment order~~ 2013-06-18
  - ~~resolve "when" field naming conflict~~ 2013-06-18
- ~~fix appointment date/time timezone issues~~ 2013-06-18
- ~~provider/appointment queue status~~ 2013-06-20
- ~~appointment notes~~ 2013-06-21
- ~~environment based config for js apps~~ 2013-06-22
- ~~versioned provider js and now rely on server version before local fallback~~ 2013-06-23
