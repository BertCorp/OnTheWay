class Customer < ActiveRecord::Base
  has_many :appointments

  validates_presence_of :name
  validates_presence_of :phone

  attr_accessible :name, :email, :phone
end
