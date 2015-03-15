class ChangeCountryToCountryCodeForLocations < ActiveRecord::Migration
  def change
    add_column :locations, :country_code, :string
  end
end
