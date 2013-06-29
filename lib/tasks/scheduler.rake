# TO RUN: heroku run rake sync:chicagocard --app onthewayhq

namespace :reminders do

  desc "(Day before at 4pm) Reminder users about their appointment."
  task :day_before => :environment do
    #to = '5857050130'
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
          message = "Reminder: You have an appointment with #{appointment.provider.name} tomorrow: #{appointment.shorturl}"
          #puts "#{appointment.to} -- #{message}"
          @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
          @client.account.sms.messages.create(
            :to => "+1#{appointment.to}",
            :from => TWILIO_FROM,
            :body => message
          )
        rescue
          # fuck it...
        end
      end
    end
  end # days_before

end
