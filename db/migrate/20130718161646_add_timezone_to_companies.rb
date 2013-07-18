class AddTimezoneToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :timezone, :string, :default => 'America/Chicago'
  end
end
