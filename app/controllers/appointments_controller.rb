class AppointmentsController < ApplicationController
  before_filter :authenticate_company!
  # GET /appointments
  def index
    if current_company.email != 'demo'
      @upcoming_appointments = current_company.appointments.where(["(appointments.starts_at >= ?) AND ((appointments.status != 'canceled') AND (appointments.status != 'finished'))", Time.zone.now.beginning_of_day]).order("appointments.starts_at ASC")
    else
      # make a special except for demo account...
      @upcoming_appointments = current_company.appointments.where(["((appointments.starts_at < ?) OR (appointments.starts_at >= ?)) AND ((appointments.status != 'canceled') AND (appointments.status != 'finished'))", '2000-01-01 00:00:00', Time.zone.now.beginning_of_day]).order("appointments.starts_at ASC")
      @upcoming_appointments.map! do |app|
        fix_demo_appointment(app)
      end
      @upcoming_appointments = @upcoming_appointments.sort_by { |k| k[:starts_at] }
    end
    @past_appointments = current_company.appointments.where(["((appointments.starts_at > ?) AND (appointments.starts_at < ?)) OR ((appointments.status = 'canceled') OR (appointments.status = 'finished'))", '2000-01-01 00:00:00', Time.zone.now.beginning_of_day]).order("appointments.starts_at DESC")
  end

  # GET /appointments/import
  def import
  end

  # POST /appointments/upload
  def upload
    #Rails.logger.info params[:file]
    uploaded_file = params[:file]
    file_contents = false
    if uploaded_file.respond_to?(:read)
      #Rails.logger.info "Responds to :read"
      file_contents = uploaded_file.read
    elsif uploaded_data.respond_to?(:path)
      #Rails.logger.info "Responds to :path"
      file_contents = File.read(uploaded_file.path)
    else
      Rails.logger.error "Bad file_data: #{uploaded_file.class.name}: #{uploaded_file.inspect}"
    end

    if file_contents
      # handle it!
      #Rails.logger.info uploaded_file
      #Rails.logger.info uploaded_file.tempfile.path
      #Rails.logger.info file_contents
      xls = Roo::Excelx.new(uploaded_file.tempfile.path, false, :ignore)
      xls.default_sheet = xls.sheets.first
      parsed_xls = xls.parse(:header_search => ['Date', 'Name'])
      parsed_xls.shift if parsed_xls[0]["Date"] == "Date"

      parsed_xls.each do |row|
        # make sure we don't already have a copy of this customer's appointment in the database
        if Appointment.joins(:customer).where(["(appointments.starts_at LIKE ?) AND (customers.email = ?)", "#{row["Date"]} %", row["Email"]]).blank?
          # create customer
          c = { name: "#{row["First Name"]} #{row["Last Name"]}", email: row["Email"], phone: (row["Contact Info."]) ? row["Contact Info."].gsub(/\D/, '') : row["Home Phone"].gsub(/\D/, '') }
          customer = Customer.find_or_create_by_email(c)
          Rails.logger.info customer.inspect
          # create appointment
          a = { starts_at: "#{row["Date"]} 00:00:00", location: "#{row["Address"]} #{row["Zip"].to_i}", company_id: current_company.id, provider_id: current_company.providers.first.id, customer_id: customer.id, notes: row["Project"], status: "confirmed" }
          Appointment.create(a)
          Rails.logger.info a.inspect
        end
      end

      #render json: parsed_xls
      redirect_to appointments_path, notice: "Your appointments have been imported. Please let us know if there were any problems."
    else
      # respond with an error
      redirect_to import_appointments_path, notice: 'There was an error uploading the file.'
    end
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
      current_company.customers << c
    end

    # build the proper when date field
    params[:appointment][:starts_at] = Time.zone.parse("#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}")

    if !params[:appointment][:status].present?
      params[:appointment][:status] = 'requested'
    end

    # save the proper status timestamps
    if (params[:appointment][:status] != 'requested') && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
      params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.zone.now
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

    if (current_company.email == 'demo') && params[:appointment][:starts_at].present?
      Time.zone = 'America/Chicago'
      params[:appointment][:starts_at][:date] = (params[:appointment][:starts_at][:date] == Date.today.to_s) ? '0001-01-01' : '0001-01-02'
    end

    # build the proper when date field
    params[:appointment][:starts_at] = Time.zone.parse("#{params[:appointment][:starts_at][:date]} #{params[:appointment][:starts_at][:time]}")

    # save the proper status timestamps
    if (params[:appointment][:status] != 'requested') && (params[:appointment][:status] != 'canceled') && !params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym].present?
      params[:appointment]["#{params[:appointment][:status].gsub(' ', '_')}_at".to_sym] = Time.zone.now
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
