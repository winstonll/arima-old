class RemoveXAxisMaxFromTags < ActiveRecord::Migration
  def change
    remove_column :tags, :x_axis_max, :integer
  end
end
