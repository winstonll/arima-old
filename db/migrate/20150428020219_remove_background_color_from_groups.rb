class RemoveBackgroundColorFromGroups < ActiveRecord::Migration
  def up
    remove_column :groups, :background_color
  end

  def down
    add_column :groups, :background_color, :string
  end
end
