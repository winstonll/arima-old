class AddReplyIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :reply_id, :integer, :default => 0
  end
end
