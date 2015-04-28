class RemoveSubscribedToBlogFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :subscribed_to_blog
  end

  def down
    add_column :users, :subscribed_to_blog, :boolean
  end
end
