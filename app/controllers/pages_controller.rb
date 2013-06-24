class PagesController < ApplicationController

  def index
    redirect_to appointments_path if current_company
  end

  def provider
    # store location
    render :layout => false;
  end

  def customer
    # show location
    render :layout => false;
  end

end
