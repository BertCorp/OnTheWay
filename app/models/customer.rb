class Customer < ActiveRecord::Base
  has_many :appointments

  attr_accessible :name, :email, :phone
end
