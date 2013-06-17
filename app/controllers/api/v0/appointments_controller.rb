class Api::V0::AppointmentsController < Api::V0::BaseApiController
  before_filter :authenticate_provider!

  def index
    @appointments = current_provider.appointments
  end

end
