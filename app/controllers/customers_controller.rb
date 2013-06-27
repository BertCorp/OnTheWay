class CustomersController < ApplicationController
  before_filter :authenticate_company!, :except => [:appointment]

  # GET /a/:id
  def appointment
    @appointment = Appointment.find_by_shortcode(params[:id])

    if @appointment.status == 'finished'
      render 'customers/appointment-feedback', layout: false
    elsif (@appointment.status == 'canceled') || (@appointment.starts_at > DateTime.now.end_of_day)
      render 'customers/appointment-invalid', layout: false
    else
      render layout: false
    end
  end

  # GET /customers
  def index
    @customers = current_company.customers.all
  end

  # GET /customers/1
  def show
    @customer = current_company.customers.find(params[:id])
  end

  # GET /customers/new
  def new
    @customer = current_company.customers.new
  end

  # GET /customers/1/edit
  def edit
    @customer = current_company.customers.find(params[:id])
  end

  # POST /customers
  def create
    @customer = current_company.customers.new(params[:customer])

    if @customer.save
      redirect_to @customer, notice: 'Customer was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /customers/1
  def update
    @customer = current_company.customers.find(params[:id])

    if @customer.update_attributes(params[:customer])
      redirect_to @customer, notice: 'Customer was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /customers/1
  def destroy
    @customer = current_company.customers.find(params[:id])
    @customer.destroy

    redirect_to customers_url
  end
end
