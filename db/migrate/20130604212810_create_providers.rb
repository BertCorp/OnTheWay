class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.integer :company_id
      t.string :name
      t.string :phone

      t.timestamps
    end
  end
end
