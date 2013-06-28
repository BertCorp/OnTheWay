module AnyBase
  ENCODER = Hash.new do |h,k|
    h[k] = Hash[ k.chars.map.with_index.to_a.map(&:reverse) ]
  end
  DECODER = Hash.new do |h,k|
    h[k] = Hash[ k.chars.map.with_index.to_a ]
  end
  def self.encode( value, keys )
    ring = ENCODER[keys]
    base = keys.length
    result = []
    until value == 0
      result << ring[ value % base ]
      value /= base
    end
    result.reverse.join
  end
  def self.decode( string, keys )
    ring = DECODER[keys]
    base = keys.length
    string.reverse.chars.with_index.inject(0) do |sum,(char,i)|
      sum + ring[char] * base**i
    end
  end
end

class Appointment < ActiveRecord::Base
  include AnyBase

  belongs_to :company
  belongs_to :provider
  belongs_to :customer

  validates_presence_of :company
  validates_presence_of :provider
  validates_presence_of :customer

  attr_accessible :company_id, :customer_id, :provider_id, :starts_at, :location
  attr_accessible :status, :notes, :rating, :feedback
  attr_accessible :confirmed_at, :en_route_at, :arrived_at, :finished_at

  def queue_position
    queue = provider.queue
    queue.each_with_index do |a, i|
      return i if a.id == self.id
    end
    false
  end

  def self.find_by_shortcode(code)
    i = AnyBase.decode(code, ([*0..9,*'a'..'z'] - %w[i o u 0 1 3]).join)
    self.find(i)
  end

  def shortcode
    AnyBase.encode(id, ([*0..9,*'a'..'z'] - %w[i o u 0 1 3]).join)
  end

  def shorturl
    "http://otwhq.co/a/#{shortcode}" # switch to http://otwhq.co/ when it's working again
  end

  def status_date
    case status
    when "canceled"
      return updated_at
    when "finished"
      return finished_at
    when "arrived"
      return arrived_at
    when "en route"
      return en_route_at
    when "confirmed"
      return confirmed_at
    else
      return created_at
    end
  end

  def statuses
    ['requested', 'confirmed', 'en route', 'arrived', 'finished', 'canceled']
  end

  def to
    p = customer.phone.gsub(/\D/, '')
    p = p.drop(1) if ((p.size == 11) && (p[0] == 1))
    p
  end

  def as_json(args={})
    super(:methods=>[:status, :shorturl, :customer], :except => [:company_id, :customer_id, :provider_id, :provider_location])
  end

end
