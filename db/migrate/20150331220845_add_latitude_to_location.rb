class AddLatitudeToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :latitude, :string
  end
end
