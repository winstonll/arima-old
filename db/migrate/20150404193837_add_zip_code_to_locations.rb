class AddZipCodeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :zip_code, :string
  end
end
