class AddColumnIpToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :ip_address, :string
  end
end
