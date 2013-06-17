class Api::V0::AppointmentsController < Api::V0::BaseApiController
  before_filter :authenticate_provider!

  def index
    @appointments = current_provider.appointments.where(['"appointments"."when" >= ?', Date.today]).order('"appointments"."when" ASC')
    render json: Hash[@appointments.map{|u| [u.id, u]}]
  end

end
