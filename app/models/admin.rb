class Admin < ActiveRecord::Base
  devise :database_authenticatable#, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  #       :token_authenticatable, :confirmable,
  #       :lockable, :timeoutable and :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :name


end
