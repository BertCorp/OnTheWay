class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :company_id, :null => false, :default => 0
      t.integer :provider_id, :null => false, :default => 0
      t.integer :customer_id, :null => false, :default => 0
      t.string :shortcode
      t.datetime :when
      t.text :where
      t.text :provider_location
      t.string :status # requested, canceled, confirmed, arrived, finished
      t.integer :rating
      t.text :feedback
      t.datetime :confirmed_at
      t.datetime :arrived_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
