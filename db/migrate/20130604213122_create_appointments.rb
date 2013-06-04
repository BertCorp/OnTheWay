class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :company_id
      t.integer :provider_id
      t.integer :customer_id
      t.string :shortcode
      t.datetime :when
      t.text :where
      t.text :provider_location
      t.string :status
      t.integer :rating
      t.text :feedback
      t.datetime :confirmed_at
      t.datetime :arrived_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
