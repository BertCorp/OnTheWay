class ApplicationController < ActionController::Base
  #protect_from_forgery
  skip_after_filter :intercom_rails_auto_include
  around_filter :set_timezone

  def after_sign_in_path_for(resource)
    return '/admin' if resource.class.name == 'Admin'
    appointments_path
  end

  def fix_demo_appointment(appointment)
    y = appointment.starts_at.to_s[0..3]
    if y == '0001'
      m = appointment.starts_at.in_time_zone('America/Chicago').to_s[5..6]
      d = appointment.starts_at.in_time_zone('America/Chicago').to_s[8..9]
      t = appointment.starts_at.in_time_zone('America/Chicago').to_s[11..15]
      appointment.starts_at = Time.zone.parse("#{Time.zone.now.year}-#{Time.zone.now.month}-#{Time.zone.now.day+(d.to_i-1)} #{t}:00")
    end
    appointment
  end

  def set_timezone
    timezone = 'America/Los_Angeles'
    if current_provider && current_provider.timezone.present?
      timezone = current_provider.timezone
    elsif current_provider && current_provider.company && current_provider.company.timezone.present?
      timezone = current_provider.company.timezone
    elsif current_company && current_company.timezone.present?
      timezone = current_company.timezone
    end
    Rails.logger.info "Set Timezone: #{timezone.inspect}"
    Time.zone = timezone
    yield
  end

end
