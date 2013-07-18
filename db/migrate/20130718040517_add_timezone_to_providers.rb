class AddTimezoneToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :timezone, :string, :default => nil
  end
end
