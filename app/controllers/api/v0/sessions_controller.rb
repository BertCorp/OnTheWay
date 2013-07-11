class Api::V0::SessionsController < Devise::SessionsController
  #prepend_before_filter :require_no_authentication, :only => [:create, :check]

  def check
    updates = {}
    # add any updates to variables that we need to. ie:
    #updates[:protocol] = 'https://'
    if params[:device_uid]
      provider = Provider.find_by_device_uid(params[:device_uid])
      updates[:provider] = { auth_token: provider.authentication_token, email: provider.email, authenticated_at: Time.now } if provider
    end

    render json: updates
  end

  def create
    build_resource

    if !params[:provider].present?
      render json: { success: false, message: "Missing required parameters for authentication." }, status: 422
      return
    end

    resource = Provider.find_for_database_authentication(email: params[:provider][:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:provider][:password])
      sign_in("user", resource)
      render json: { success: true, auth_token: resource.authentication_token, email: resource.email, authenticated_at: Time.now }
      return
    end
    invalid_login_attempt
  end

  def destroy
    token_was_removed = false
    if current_provider
      current_provider.authentication_token = nil
      token_was_removed = current_provider.save
    end
    sign_out(resource_name)
    if token_was_removed
      render status: 200, json: { status: true, message: "Logout successful." }
    else
      render status: 401, json: { status: false, message: "Logout failed. Invalid token or some internal server error occurred during attempt." }
    end
  end

  protected
  def invalid_login_attempt
    warden.custom_failure!
    render json: { success: false, message: "Error with your email or password. Please try again." }, status: 401
  end
end
