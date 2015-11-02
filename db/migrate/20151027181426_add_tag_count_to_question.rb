class AddTagCountToQuestion < ActiveRecord::Migration
  def change
  	add_column :questions, :tag_count, :integer, :default => 0
  end
end
