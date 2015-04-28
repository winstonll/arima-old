class RemoveTextColorFromGroups < ActiveRecord::Migration
  def up
    remove_column :groups, :text_color
  end

  def down
    add_column :groups, :text_color, :string
  end
end
