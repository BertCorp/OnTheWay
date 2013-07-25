class Company < ActiveRecord::Base
  has_many :appointments
  has_many :providers
  has_and_belongs_to_many :customers

  validates_presence_of :name
  validates :email,
    :presence => { :message => "Please provide a valid email. It is used for login and notification purposes." },
    :uniqueness => { :case_sensitive => false },
    :format => { :with => /\A[^@]+@[^@]+\z/ },
    :if => :email_required?
  validates_presence_of :phone

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable#, :validatable
         # :token_authenticatable, :confirmable,
         # :lockable, :timeoutable and :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :phone, :timezone

  private

  def email_required?
    email != 'demo'
  end

end
