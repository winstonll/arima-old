class AddXAxisToTags < ActiveRecord::Migration
  def change
    add_column :tags, :x_axis, :integer
  end
end
