OnTheWay
========

- Customer Web Panel: http://www.onthewayhq.com
  - demo // demo
- Provider Mobile Web App: http://otwhq.com/p
  - demo // demo


Mockups
=======
- Provider Mobile App: http://www.onthewayhq.com/mobile/
- Customer Appointment: http://www.onthewayhq.com/customer/
- Customer Feedback: http://www.onthewayhq.com/feedback/


Deployment
==========
- Precompile assets: `RAILS_ENV=production bundle exec rake assets:precompile`
- Commit to github: `git commit -am "Commit Message"` `git push origin master`
- Deploy to staging: `git push staging master`
- Deploy to production: `git push heroku master`


Todos
=====
- more reliable scheduling/jobs
- extract txt message error handling
- add provider notification settings
- provider push/sms notifications
  - if provider hasn't marked job as finished, send him a friendly reminder to.
- translation layer
  - need to figure out appointment types
- simpler company/provider signup


Down the Road
=============
- Providers
  - appointment types/tags
  - metadata fields (ability for companies/providers to add custom fields to appointments)
  - better offline handling
  - listview pull to refresh -- https://github.com/watusi/jquery-mobile-iscrollview
- activity log -- http://railscasts.com/episodes/406-public-activity
- full CRM functionality
- build out sms reply system


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
- ~~install new relic~~ 2013-06-25
- ~~up dynos~~ 2013-06-25
- ~~basic functional mobile prototype for providers~~
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
- ~~mobile prototype for customers~~
  - ~~dynamic~~ 2013-06-19
  - ~~cancel appointment~~ 2013-06-19
  - ~~customer feedback~~ 2013-06-19
    - ~~figure out auth token situation for api access~~ 2013-06-19
  - ~~provider tracking~~ 2013-06-25
  - ~~add eta/last of on map/directions page.~~ 2013-06-25
  - ~~auto update queue/eta~~ 2013-06-25
- ~~basic appointment ETA~~ 2013-06-25
  - ~~https://developers.google.com/maps/documentation/javascript/reference#DirectionsService~~
- ~~add google analytics~~ 2013-06-26
- ~~deploy mark's splash/marketing page~~ 2013-06-26
- ~~install intercom to track user engagement~~ 2013-06-26
- ~~twilio integration~~ 2013-06-27
  - ~~account setup and funded~~ 2013-06-22
- ~~send daily appointment reminders~~ 2013-06-27
- ~~if appointment is made after 4pm the day before, send a txt upon creation.~~ 2013-06-27
- ~~send text when provider is on the way to appointment~~ 2013-06-27
- ~~send text when appointment is finished~~ 2013-06-27
- ~~company/provider customer and appointment import tools for Michael~~ 2013-06-28
- ~~fix crashing issue with precompiled assets~~ 2013-06-28
- ~~add exception monitoring~~ 2013-06-28
- ~~setup basic staging~~ 2013-06-28
- ~~Fix twilio exception when calling a bad number~~ 2013-06-28
- ~~Better phone number input mask~~ 2013-06-28
- ~~native apps via phonegap~~ 2013-07-03
- ~~update demo login~~ 2013-07-10
- ~~dynamic content in prototype~~ 2013-07-10
- ~~fix intercom tracking~~ 2013-07-11
- ~~provider tracking in api/apps~~ 2013-07-11
- ~~better feedback on appointment page instructing when texts will go out.~~ 2013-07-11
- ~~fix queue position "next" issue~~ 2013-07-11
- ~~sms reply~~ 2013-07-11
- ~~add appointment shorturls to admin panel records~~ 2013-07-12
- ~~better location validation and handling for web panel~~ 2013-07-12
- ~~fix bad destination/location input google parse issues for mobile apps~~ 2013-07-12
- ~~phonegap analytics -- https://github.com/ggendre/GALocalStorage~~ 2013-07-12
- ~~new name iOS app to just OnTheWay (drop Provider)~~ 2013-07-12
- ~~rework app buttons to better reflect native Apple conventions~~ 2013-07-17
- ~~add ability to delete an appointment~~ 2013-07-17
- ~~added a default time to new appointments to help provide suggested input format~~ 2013-07-17
- ~~add provider timezones~~ 2013-07-18
  - ~~basic site integration for displaying times properly based on company/provider timezone~~ 2013-07-18
  - ~~ability for companies and providers to choose/change their timezones~~ 2013-07-18
