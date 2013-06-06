class PagesController < ApplicationController

  def index
    redirect_to appointments_path if current_company
  end

  def provider
    # store location
  end

  def customer
    # show location
  end

end
