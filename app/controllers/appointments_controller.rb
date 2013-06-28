class AppointmentsController < ApplicationController
  before_filter :authenticate_company!
  # GET /appointments
  def index
    Rails.logger.info Date.today.to_time
    @upcoming_appointments = current_company.appointments.where(["(appointments.starts_at >= ?) AND ((appointments.status != 'canceled') AND (appointments.status != 'finished'))", DateTime.now.beginning_of_day]).order("appointments.starts_at ASC")
    @past_appointments = current_company.appointments.where(["(appointments.starts_at < ?) OR ((appointments.status = 'canceled') OR (appointments.status = 'finished'))", DateTime.now.beginning_of_day]).order("appointments.starts_at DESC")
  end

  # GET /appointments/import
  def import
  end

  # POST /appointments/import
  def import_create

  end

  # GET /appointments/1
  def show
    @appointment = Appointment.find(params[:id])
  end

  # GET /appointments/new
  def new
    @appointment = current_company.appointments.new
    @appointment.provider_id = current_company.providers.first.id if (current_company.providers.count == 1)
    @appointment.status = 'confirmed'
  end

  # GET /appointments/1/edit
  def edit
    @appointment = current_company.appointments.find(params[:id])
  end

  # POST /appointments
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
      redirect_to @appointment, notice: 'Appointment was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /appointments/1
  def update
    @appointment = current_company.appointments.find(params[:id])
    orig_status = @appointment.status
    orig_time = @appointment.starts_at

    params[:appointment][:starts_at] = "#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}"

    # save the proper status timestamps
    if (params[:appointment][:status] != 'requested') && (params[:appointment][:status] != 'canceled') && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
      params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.now
    end

    if @appointment.update_attributes(params[:appointment])
      if params[:appointment][:starts_at] && (orig_time.to_s[0..15] != params[:appointment][:starts_at]) && (params[:appointment][:starts_at] < orig_time.to_s[0..15])
        @appointment.send_reminder
      end
      if (orig_status != 'en route') && (params[:appointment][:status] == 'en route')
        @appointment.send_en_route_notification
      end
      if (orig_status != 'finished') && (params[:appointment][:status] == 'finished')
        @appointment.send_feedback_request
      end

      redirect_to @appointment, notice: 'Appointment was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /appointments/1
  def destroy
    @appointment = current_company.appointments.find(params[:id])
    @appointment.destroy

    redirect_to appointments_url
  end

end
