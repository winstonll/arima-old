class AddYAxisMaxToTags < ActiveRecord::Migration
  def change
    add_column :tags, :y_axis_max, :integer
  end
end
