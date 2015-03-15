class AddSubscribedToBlogToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribed_to_blog, :boolean, default: false
  end
end
