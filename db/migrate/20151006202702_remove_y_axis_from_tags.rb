class RemoveYAxisFromTags < ActiveRecord::Migration
  def change
    remove_column :tags, :y_axis, :integer
  end
end
