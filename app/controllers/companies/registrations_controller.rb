class Companies::RegistrationsController < Devise::RegistrationsController

  def update
    Rails.logger.info "GO BACK TO APPOINTMENTS!!!"
    session["#{resource_name}_return_to"] = appointments_path
    super
  end

  protected

  def after_update_path_for(resource)
    appointments_path
  end

end
