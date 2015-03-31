class AddLongitudeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :longitude, :float
  end
end
