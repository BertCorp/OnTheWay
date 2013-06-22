class Api::V0::AppointmentsController < Api::V0::BaseApiController
  before_filter :authenticate_provider!, :except => [:feedback, :tracking_show]

  # GET /appointments.json
  def index
    @appointments = current_provider.appointments.where(['appointments.starts_at >= ?', DateTime.now.beginning_of_day]).order('appointments.starts_at ASC')
    render json: @appointments
  end

  # GET /appointments/1.json
  def show
    @appointment = current_provider.appointments.find(params[:id])
    render json: @appointment
  end

  # POST /appointments.json
  def create
    # since we know the provider (from auth_token), we also know the company
    params[:appointment][:company_id] = current_provider.company.id
    #params[:appointment][:provider_id] = current_provider.id

    # save new customer
    if params[:appointment][:customer].present?
      c = Customer.new(params[:appointment][:customer])
      if c.save
        params[:appointment][:customer_id] = c.id
      end
      params[:appointment].delete(:customer)
    end

    # build the proper when date field
    params[:appointment][:starts_at] = "#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}"

    if !params[:appointment][:status].present?
      params[:appointment][:status] = 'confirmed'
    end

    # save the proper status timestamps
    if (params[:appointment][:status] != 'requested') && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
      params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.now
    end

    @appointment = current_provider.appointments.new(params[:appointment])

    if @appointment.save
      render json: @appointment, status: :created, location: @appointment
    else
      render json: { message: "There was an error creating the appointment.", errors: @appointment.errors }, status: :unprocessable_entity
    end
  end

  # PUT /appointments/1.json
  def update
    @appointment = current_provider.appointments.find(params[:id])

    params[:appointment][:starts_at] = "#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}" if params[:appointment][:starts_at]

    # do what you need to do...
    if (params[:appointment][:status])
      # save the proper status timestamps -- dont need requested, canceled
      if !['requested', 'canceled'].include?(params[:appointment][:status]) && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
        params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.now
      end

      params[:appointment][:en_route_at] = nil if !['finished', 'arrived', 'en route', 'canceled'].include? params[:appointment][:status]
      params[:appointment][:arrived_at] = nil if !['finished', 'arrived', 'canceled'].include? params[:appointment][:status]
      params[:appointment][:finished_at] = nil if (params[:appointment][:status] != 'finished')
    end

    if @appointment.update_attributes(params[:appointment])
      render json: @appointment
    else
      render json: { message: "There was an error updating the appointment.", errors: @appointment.errors }, status: :unprocessable_entity
    end
  end

  # PUT /appointments/1/feedback.json
  def feedback
    @appointment = Appointment.find(params[:id])

    params[:appointment].select! {|k,v| ["rating", "feedback"].include?(k) }

    if @appointment.update_attributes(params[:appointment])
      render json: @appointment
    else
      render json: { message: "There was an error submitting your appointment feedback.", errors: @appointment.errors }, status: :unprocessable_entity
    end
  end

  # GET /appointments/1/tracking.json
  def tracking_show
    @appointment = Appointment.find(params[:id])
    if @tracking = $redis.get("provider-#{@appointment.provider.id}")
      render json: ActiveSupport::JSON.decode(@tracking)
    else
      render json: { message: "There was an error getting provider's current location." }, status: :unprocessable_entity
    end
  end

  # PUT /appointments/1/tracking.json
  def tracking_update
    @appointment = current_provider.appointments.find(params[:id])
    # figure out ETA based on new info?
    if @tracking = $redis.set("provider-#{current_provider.id}", params[:tracking].to_json)
      render json: {}
    else
      render json: { message: "There was an error updating your current location." }, status: :unprocessable_entity
    end
  end

end
