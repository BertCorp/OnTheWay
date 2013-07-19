# TO RUN: heroku run rake sync:chicagocard --app onthewayhq

namespace :reminders do

  desc "(Day before at 6pm CST) Remind users about their appointment."
  task :day_before => :environment do
    # what is the current utc hour?
    # figure out if its 4pm in any of the current timezones.
    # get all the appointments for that timezone
    Time.zone = 'Central Time (US & Canada)'
    # get all appointments tomorrow that haven't happened yet:
    sql = ["SELECT * FROM appointments WHERE ((status = 'requested') OR (status = 'confirmed')) AND (starts_at BETWEEN ? AND ?)", (Time.zone.now.beginning_of_day + 1.day).in_time_zone, (Time.zone.now.beginning_of_day + 2.days).in_time_zone]
    appointments = Appointment.find_by_sql(sql)

    #puts sql.inspect
    #puts appointments.inspect

    appointments.each do |appointment|
      # ignore 555 numbers
      if appointment.to[0..2] != '555'
        begin
          message = "Reminder: You have an appointment with #{appointment.provider.name} of #{appointment.company.name} tomorrow: #{appointment.shorturl}"
          #puts "#{appointment.to} -- #{message}"
          @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
          @client.account.sms.messages.create(
            :to => "+1#{appointment.to}",
            :from => TWILIO_FROM,
            :body => message
          )
        rescue
          # should probably log these exceptions.
          #puts "Failed to send to: #{appointment.to}"
          @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
          @client.account.sms.messages.create(
            :to => "+15857050130",
            :from => TWILIO_FROM,
            :body => "Error! Txt didnt send to: #{appointment.to}"
          )
        end
      end
    end
  end # days_before

end
