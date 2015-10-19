class AddLevelToTags < ActiveRecord::Migration
  def change
    add_column :tags, :level, :integer, :default => 0
  end
end
