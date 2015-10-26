class AddXRatioToTags < ActiveRecord::Migration
  def change
    add_column :tags, :x_ratio, :float
  end
end
