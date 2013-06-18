class Api::V0::AppointmentsController < Api::V0::BaseApiController
  before_filter :authenticate_provider!

  def index
    @appointments = current_provider.appointments.where(['appointments.starts_at >= ?', Date.today]).order('appointments.starts_at ASC')
    render json: @appointments
  end

end
