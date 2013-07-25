class Customer < ActiveRecord::Base
  has_many :appointments
  has_and_belongs_to_many :companies

  validates_presence_of :name
  validates_presence_of :phone

  attr_accessible :name, :email, :phone
  attr_accessible :company_ids
end
