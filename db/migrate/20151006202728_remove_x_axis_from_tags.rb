class RemoveXAxisFromTags < ActiveRecord::Migration
  def change
    remove_column :tags, :x_axis, :integer
  end
end
