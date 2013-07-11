class ApplicationController < ActionController::Base
  #protect_from_forgery

  def after_sign_in_path_for(resource)
    return '/admin' if resource.class.name == 'Admin'
    appointments_path
  end

  def fix_demo_appointment(appointment)
    y = appointment.starts_at.to_s[0..3]
    if y == '0001'
      m = appointment.starts_at.to_s[5..6]
      d = appointment.starts_at.to_s[8..9]
      t = appointment.starts_at.to_s[11..18]
      appointment.starts_at = "#{Time.now.year}-#{Time.now.month}-#{Time.now.day+(d.to_i-1)} #{t}"
    end
    appointment
  end

end
