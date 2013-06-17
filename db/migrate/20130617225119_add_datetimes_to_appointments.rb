class AddDatetimesToAppointments < ActiveRecord::Migration
  def up
    change_table :appointments do |t|
      t.datetime   :next_at
      t.datetime   :en_route_at
    end
  end

  def down
    change_table :appointments do |t|
      t.remove :next_at, :en_route_at
    end
  end
end
