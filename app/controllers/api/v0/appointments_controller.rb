class Api::V0::AppointmentsController < Api::V0::BaseApiController
  before_filter :authenticate_provider!, :except => [:feedback, :tracking_show]
  after_filter :update_intercom, :except => [:feedback, :tracking_show]

  # GET /appointments.json
  def index
    if current_provider.email != 'demo'
      #Rails.logger.info "Not DEMO!"
      @appointments = current_provider.appointments.where(['appointments.starts_at >= ?', Time.zone.now.beginning_of_day]).order('appointments.starts_at ASC')
    else
      #Rails.logger.info "IS DEMO!"
      # make a special except for demo account...
      #apps = current_provider.appointments.order('appointments.starts_at ASC')
      apps = current_provider.appointments.where(["(appointments.starts_at < ?) OR (appointments.starts_at >= ?)", '2000-01-01 00:00:00', Time.zone.now.beginning_of_day]).order("appointments.starts_at ASC")
      apps.map! do |app|
        fix_demo_appointment(app)
      end
      @appointments = apps.sort_by { |k| k[:starts_at] }
    end
    render json: @appointments
  end

  # GET /appointments/1.json
  def show
    @appointment = current_provider.appointments.find(params[:id])
    @appointment = fix_demo_appointment(@appointment) if current_provider.email == 'demo'
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
        current_provider.company.customers << c
      end
      params[:appointment].delete(:customer)
    end

    # build the proper when date field
    params[:appointment][:starts_at] = Time.zone.parse("#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}")

    if !params[:appointment][:status].present?
      params[:appointment][:status] = 'confirmed'
    end

    # save the proper status timestamps
    if (params[:appointment][:status] != 'requested') && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
      params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.zone.now
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
    orig_status = @appointment.status
    orig_time = @appointment.starts_at

    if (current_provider.email == 'demo') && params[:appointment][:starts_at].present?
      Time.zone = 'America/Chicago'
      params[:appointment][:starts_at][:date] = (params[:appointment][:starts_at][:date] == Date.today.to_s) ? '0001-01-01' : '0001-01-02'
    end

    params[:appointment][:starts_at] = Time.zone.parse("#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}") if params[:appointment][:starts_at]

    # do what you need to do...
    if (params[:appointment][:status])
      # save the proper status timestamps -- dont need requested, canceled
      if !['requested', 'canceled'].include?(params[:appointment][:status]) && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
        params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.zone.now
      end

      params[:appointment][:en_route_at] = nil if !['finished', 'arrived', 'en route', 'canceled'].include? params[:appointment][:status]
      params[:appointment][:arrived_at] = nil if !['finished', 'arrived', 'canceled'].include? params[:appointment][:status]
      params[:appointment][:finished_at] = nil if (params[:appointment][:status] != 'finished')
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

      render json: @appointment
    else
      render json: { message: "There was an error updating the appointment.", errors: @appointment.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /appointments/1
  def destroy
    @appointment = current_provider.appointments.find(params[:id])
    @appointment.destroy

    head :no_content
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
    queue_text = false
    queue_text = (@appointment.queue_position < 1) ? "you are <strong>next</strong>!" : " #{(@appointment.queue_position > 1) ? 'are' : 'is'} <strong>#{TextHelper.pluralize(@appointment.queue_position, "person")}</strong> in front of you." if @appointment.queue_position

    if @tracking = $redis.get("provider-#{@appointment.provider.id}")
      resp = ActiveSupport::JSON.decode(@tracking)
      resp[:queue] = @appointment.queue_position
      resp[:queue_text] = queue_text
      render json: resp
    else
      render json: { queue: @appointment.queue_position, queue_text: queue_text }
      #{ message: "There was an error getting provider's current location." }, status: :unprocessable_entity
    end
  end

  # PUT /appointments/1/tracking.json
  def tracking_update
    @appointment = current_provider.appointments.find(params[:id])
    # figure out ETA based on new info?
    # { start, current, appointment_id }
    if @tracking = $redis.set("provider-#{@appointment.provider.id}", params[:tracking].to_json)
      render json: {}
    else
      render json: { message: "There was an error updating your current location." }, status: :unprocessable_entity
    end
  end

  # DELETE /appointments/1/tracking.json
  def tracking_destroy
    @appointment = current_provider.appointments.find(params[:id])
    if @appointment
      $redis.del("provider-#{@appointment.provider.id}")
      head :no_content
    else
      render json: { message: "I'm sorry, Dave. I'm afraid I can't do that." }, status: :unauthorized
    end
  end

  def update_intercom
    #Rails.logger.info "update intercom has been called! #{current_provider.id}"
    return false unless ENV['INTERCOM_APP_ID']
    begin
      user = Intercom::User.find_by_user_id("provider::#{current_provider.id}")
      user.custom_data["type"] = "provider"
      user.custom_data["total_appointments"] = current_provider.appointments.count
      user.custom_data["finished_appointments"] = current_provider.appointments.where(:status => 'finished').count
      user.company = {
        :id => "company::#{current_provider.company.id}",
        :name => current_provider.company.name,
        :created_at => current_provider.company.created_at.to_i,
        "providers" => current_provider.company.providers.count,
        "total_appointments" => current_provider.company.appointments.count,
        "finished_appointments" => current_provider.company.appointments.where(:status => 'finished').count
      }
      user.save
    rescue Intercom::ResourceNotFound
      user = Intercom::User.new({ :user_id => "provider::#{current_provider.id}", :email => current_provider.email, :created_at => current_provider.created_at.to_i, :name => current_provider.name })
      user.custom_data['type'] = "provider"
      user.custom_data["total_appointments"] = current_provider.appointments.count
      user.custom_data["finished_appointments"] = current_provider.appointments.where(:status => 'finished').count
      user.company = {
        :id => "company::#{current_provider.company.id}",
        :name => current_provider.company.name,
        :created_at => current_provider.company.created_at.to_i,
        "providers" => current_provider.company.providers.count,
        "total_appointments" => current_provider.company.appointments.count,
        "finished_appointments" => current_provider.company.appointments.where(:status => 'finished').count
      }
      user.save
    end
    Intercom::Impression.create(:user_id => "provider::#{current_provider.id}", :location => request.fullpath, :user_ip => request.remote_ip, :user_agent => request.env['HTTP_USER_AGENT']) if user

  end

end
