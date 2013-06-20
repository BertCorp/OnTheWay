class Provider < ActiveRecord::Base
  belongs_to :company
  has_many :appointments
  has_many :customers, :through => :appointments

  validates_presence_of :company
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :phone


  before_save :ensure_authentication_token

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, #:validatable
         :token_authenticatable#, :confirmable,
         # :lockable, :timeoutable and :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :company_id, :name, :phone, :authentication_token


end
