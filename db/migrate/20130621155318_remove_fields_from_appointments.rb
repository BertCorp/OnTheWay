class RemoveFieldsFromAppointments < ActiveRecord::Migration
  def up
    change_table :appointments do |t|
      t.remove :next_at, :provider_location
    end
  end

  def down
    change_table :appointments do |t|
      t.text :provider_location
      t.datetime   :next_at
    end
  end
end
