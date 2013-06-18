class FixAppointmentColumnName < ActiveRecord::Migration
  def change
    rename_column :appointments, :where, :location
    rename_column :appointments, :when, :starts_at
  end
end
