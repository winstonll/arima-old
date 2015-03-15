class AddDefaultToUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :points, 0
  end
end
