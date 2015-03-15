class AddLastEmailedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_emailed_at, :datetime
  end
end
