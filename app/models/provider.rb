class Provider < ActiveRecord::Base
  belongs_to :company
  has_many :appointments
  has_many :customers, :through => :appointments

  validates_presence_of :company
  validates_presence_of :name
  #validates_presence_of :email
  validates :email,
    :presence => { :message => "must be valid, as it is used for login and notification purposes." },
    :uniqueness => { :case_sensitive => false },
    :format => { :with => /\A[^@]+@[^@]+\z/ },
    :if => :email_required?
  validates_presence_of :phone


  before_save :ensure_authentication_token

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, #:validatable
         :token_authenticatable #, :confirmable,
         # :lockable, :timeoutable and :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :company_id, :name, :phone, :authentication_token

  def queue
    if email != 'demo'
      appointments.where(['(appointments.starts_at BETWEEN ? AND ?) AND (status != ?) AND (status != ?)', DateTime.now.beginning_of_day, DateTime.now.end_of_day, 'finished', 'canceled']).order('appointments.starts_at ASC')
    else
      appointments.where(['(appointments.starts_at BETWEEN ? AND ?) AND (status != ?) AND (status != ?)', '0001-01-01 00:00:00', '0001-01-01 23:59:59', 'finished', 'canceled']).order('appointments.starts_at ASC')
    end
  end

  private

  def email_required?
    email != 'demo'
  end

end
