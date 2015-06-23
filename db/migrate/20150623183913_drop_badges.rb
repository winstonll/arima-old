class DropBadges < ActiveRecord::Migration
  def change
    drop_table :badges
  end
end
