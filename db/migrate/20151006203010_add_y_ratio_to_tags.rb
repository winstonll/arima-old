class AddYRatioToTags < ActiveRecord::Migration
  def change
    add_column :tags, :y_ratio, :float
  end
end
