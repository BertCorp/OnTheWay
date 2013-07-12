class PagesController < ApplicationController

  def index
    # redirect_to appointments_path if current_company
    render :layout => false
  end

  def landing_confirmation
    render :layout => false
  end

  def pro_marketing
    render :layout => false
  end

  def pro_marketing_confirmation
    render :layout => false
  end

  def sms_reply
    render :layout => false, :content_type => "text/xml"
  end

  def provider
    # store location
    render :layout => false
  end

  def customer
    # show location
    render :layout => false
  end

end
