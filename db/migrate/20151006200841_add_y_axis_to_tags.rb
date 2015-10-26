class AddYAxisToTags < ActiveRecord::Migration
  def change
    add_column :tags, :y_axis, :integer
  end
end
