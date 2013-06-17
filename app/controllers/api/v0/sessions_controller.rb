class Api::V0::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [:create]

  respond_to :json

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
    sign_out(resource_name)
  end

  protected
  def invalid_login_attempt
    warden.custom_failure!
    render json: { success: false, message: "Error with your email or password. Please try again." }, status: 401
  end
end
