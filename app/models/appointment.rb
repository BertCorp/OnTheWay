class Appointment < ActiveRecord::Base
  attr_accessible :arrived_at, :company_id, :confirmed_at, :customer_id, :feedback, :finished_at, :provider_id, :provider_location, :rating, :shortcode, :status, :when, :where
end
