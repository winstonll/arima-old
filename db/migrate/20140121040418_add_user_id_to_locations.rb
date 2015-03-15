class AddUserIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :user_id, :integer
  end
end
