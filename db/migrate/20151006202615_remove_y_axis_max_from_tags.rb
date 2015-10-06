class RemoveYAxisMaxFromTags < ActiveRecord::Migration
  def change
    remove_column :tags, :y_axis_max, :integer
  end
end
