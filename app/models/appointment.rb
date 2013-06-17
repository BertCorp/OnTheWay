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

  attr_accessible :arrived_at, :company_id, :confirmed_at, :customer_id, :feedback, :finished_at, :provider_id, :provider_location, :rating, :status, :when, :where

  def self.find_by_shortcode(code)
    i = AnyBase.decode(code, ([*0..9,*'a'..'z'] - %w[i o u 0 1 3]).join)
    self.find(i)
  end

  def shortcode
    AnyBase.encode(id, ([*0..9,*'a'..'z'] - %w[i o u 0 1 3]).join)
  end

  def shorturl
    "http://otwhq.co/#{shortcode}"
  end

  def status_date
    case status
    when "canceled"
      return updated_at
    when "finished"
      return finished_at
    when "arrived"
      return arrived_at
    when "confirmed"
      return confirmed_at
    else
      return created_at
    end
  end

  def statuses
    ['requested', 'confirmed', 'arrived', 'finished', 'canceled']
  end

  def as_json(args={})
    super(:methods=>[:status, :shorturl, :customer], :except => [:company_id, :customer_id, :provider_id, :provider_location])
  end

end
