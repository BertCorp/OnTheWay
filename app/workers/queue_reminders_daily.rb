class QueueReminders
  @queue = :reminders

  def self.perform
    # check what hour it is.
    # grab all companies/providers that are set to send reminders at this hour
    # grab all reminders for this day
    # how do we do hours before?

    # reminder settings:
    # 0 = 8am the day before
    # 8 = 4pm the day before
    # 16 = midnight
    # 24 = 8am, the day of appointment

  end

end
