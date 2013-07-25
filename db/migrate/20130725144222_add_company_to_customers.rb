class AddCompanyToCustomers < ActiveRecord::Migration
  def change
    create_table :companies_customers do |t|
      t.belongs_to :company
      t.belongs_to :customer
    end
  end
end
