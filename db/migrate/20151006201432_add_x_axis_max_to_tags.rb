class AddXAxisMaxToTags < ActiveRecord::Migration
  def change
    add_column :tags, :x_axis_max, :integer
  end
end
