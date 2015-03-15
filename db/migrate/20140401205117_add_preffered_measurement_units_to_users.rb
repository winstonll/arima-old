class AddPrefferedMeasurementUnitsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :measurement_unit, :string
    add_column :users, :currency_unit, :string
  end
end
