class Api::V0::AppointmentsController < Api::V0::BaseApiController
  before_filter :authenticate_provider!

  # GET /appointments.json
  def index
    @appointments = current_provider.appointments.where(['appointments.starts_at >= ?', Date.today]).order('appointments.starts_at ASC')
    render json: @appointments
  end

  # GET /appointments/1.json
  def show
    @appointment = current_company.appointments.find(params[:id])
    render json: @appointment
  end

  # POST /appointments.json
  def create
    # save new customer
    if params[:appointment][:customer].present?
      c = Customer.new(params[:appointment][:customer])
      c.save
      params[:appointment].delete(:customer)
      params[:appointment][:customer_id] = c.id
    end

    # build the proper when date field
    params[:appointment][:starts_at] = "#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}"

    if !params[:appointment][:status].present?
      params[:appointment][:status] = 'requested'
    end

    # save the proper status timestamps
    if (params[:appointment][:status] != 'requested') && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
      params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.now
    end

    @appointment = current_company.appointments.new(params[:appointment])

    if @appointment.save
      render json: @appointment, status: :created, location: @appointment
    else
      render json: @appointment.errors, status: :unprocessable_entity
    end
  end

  # PUT /appointments/1.json
  def update
    @appointment = current_company.appointments.find(params[:id])

    # do what you need to do...
    if (params[:appointment][:status])
      # save the proper status timestamps -- dont need requested, canceled
      if ((params[:appointment][:status] != 'requested') && (params[:appointment][:status] != 'canceled'))
        params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.now
      end

    end

    if @appointment.update_attributes(params[:appointment])
      head :no_content
    else
      render json: @appointment.errors, status: :unprocessable_entity
    end
  end

end
